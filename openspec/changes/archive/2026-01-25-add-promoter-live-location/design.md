## Context

Live location tracking is critical for Promoruta's business model - it validates campaign execution and enables payment based on verified routes. The implementation must balance:
- **Accuracy**: GPS precision for route validation
- **Battery life**: Promoters may run campaigns for hours
- **Reliability**: Must work with intermittent connectivity
- **User experience**: Smooth map rendering and minimal UI lag

### Constraints

- Must work in foreground (background tracking is a future enhancement)
- Android requires foreground service notification for continuous location
- iOS has different location tracking lifecycle and permission model
- Mapbox free tier: 50k map loads, 100k routing requests/month

### Platform Differences

| Aspect | Android | iOS |
|--------|---------|-----|
| Permission model | Fine/Coarse location | When In Use / Always + Precise/Approximate |
| Foreground tracking | Requires foreground service with notification | Works with "When In Use" permission |
| Background tracking | Foreground service continues in background | Requires "Always" permission + background mode |
| Battery optimization | Doze mode can throttle updates | iOS manages automatically |
| Location accuracy | High/Medium/Low enum | Full Accuracy toggle (iOS 14+) |

## Goals / Non-Goals

### Goals
- Real-time location display on Mapbox map during active campaign
- GPS coordinate collection at configurable intervals
- Periodic batch upload to backend with offline resilience
- Visual route path (polyline) showing traveled distance
- Campaign execution lifecycle (start → pause → resume → complete)
- **Single active campaign enforcement** - Promoter can only execute one campaign at a time
- **Campaign audio playback** - Play the advertiser's audio file during campaign execution

### Non-Goals (Future Work)
- Background location tracking when app is minimized
- Turn-by-turn navigation
- Geofencing for campaign zones
- Real-time location sharing with advertisers (requires WebSocket)
- ~~Audio playback integration~~ (now included in scope)
- Automatic audio looping/scheduling

## Decisions

### 1. Location Update Strategy

**Decision**: Use distance-based updates with time fallback

```dart
LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10, // meters - trigger update when moved 10m
  timeLimit: Duration(seconds: 30), // fallback: at least every 30s
)
```

**Rationale**: Pure time-based updates waste battery when stationary. Distance-based updates ensure we capture actual movement while conserving battery during stops.

### 2. GPS Data Batching

**Decision**: Batch and upload every 60 seconds or 20 points (whichever first)

**Rationale**:
- Reduces API calls and battery usage vs real-time streaming
- 60s window balances data freshness with efficiency
- 20 points cap prevents large payloads on fast routes

### 3. State Management

**Decision**: Use dedicated `CampaignExecutionNotifier` (Riverpod StateNotifier)

```dart
enum CampaignExecutionStatus { idle, starting, active, paused, completing, completed }

class CampaignExecutionState {
  final CampaignExecutionStatus status;
  final String? activeCampaignId;
  final List<GpsPoint> pendingPoints;
  final DateTime? startedAt;
  final double distanceTraveled;
}
```

**Rationale**: Clean separation between execution state and GPS data. StateNotifier provides immutable state updates suitable for UI reactivity.

### 4. Offline Resilience

**Decision**: Store GPS points in local Drift database, mark as synced after successful upload

**Tables**:
- `GpsPoints` (existing) - stores individual coordinates
- Add `syncedAt` nullable column to track upload status

**Rationale**: Leverages existing Drift infrastructure. Simple sync flag enables retry logic without complex queuing.

### 5. Map Integration

**Decision**: Use Mapbox `PointAnnotation` for current location, `PolylineAnnotation` for route

**Rationale**:
- Mapbox's annotation API is designed for this use case
- PolylineAnnotation efficiently handles growing coordinate lists
- Better performance than rebuilding map layers

### 5a. Single Active Campaign Constraint

**Decision**: Enforce single campaign execution at the state management level

```dart
// In CampaignExecutionNotifier
Future<bool> startExecution({required String campaignId}) async {
  if (state.hasActiveExecution) {
    AppLogger.location.w('Cannot start: execution already in progress');
    return false; // Reject new campaign start
  }
  // ... proceed with execution
}
```

**Rationale**:
- Simplifies GPS tracking (only one active stream)
- Clear user experience - no confusion about which campaign is active
- Prevents conflicting audio playback
- Backend sync is simpler with single campaign context
- Business rule: promoter should focus on completing one campaign before starting another

### 5b. Campaign Audio Playback

**Decision**: Use `just_audio` package for audio playback with stream support

```dart
class CampaignAudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> loadCampaignAudio(String audioUrl) async {
    await _player.setUrl(audioUrl);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}
```

**Audio URL Source**: Campaign model includes `audio_file_path` from advertiser upload

**UI Integration**:
- Audio player controls in bottom section of ActiveCampaignMapView
- Play/Pause button, progress bar, elapsed/total time
- Audio continues during pause (promoter at traffic light can still play audio)

**Rationale**:
- `just_audio` supports streaming, caching, and background playback
- Separate from GPS tracking - audio can play/pause independently
- Promoter can replay audio multiple times during campaign
- Works offline if audio was previously cached

### 6. iOS-Specific Location Handling

**Decision**: Use platform-specific location settings via Geolocator's `AppleSettings`

```dart
// iOS-specific settings
AppleSettings(
  accuracy: LocationAccuracy.high,
  activityType: ActivityType.automotiveNavigation, // Optimized for vehicle movement
  distanceFilter: 10,
  pauseLocationUpdatesAutomatically: false, // Don't auto-pause during campaign
  showBackgroundLocationIndicator: true, // Blue status bar indicator
  allowBackgroundLocationUpdates: false, // v1: foreground only
)
```

**Rationale**:
- `activityType.automotiveNavigation` - iOS optimizes GPS for vehicle movement patterns
- `pauseLocationUpdatesAutomatically: false` - Prevents iOS from pausing updates during stops
- `showBackgroundLocationIndicator: true` - Shows blue bar when app uses location (trust signal)

### 7. iOS Permission Flow

**Decision**: Request "When In Use" permission for v1, with clear upgrade path to "Always"

**Permission sequence**:
1. Check current authorization status
2. If `notDetermined` → show custom pre-permission dialog explaining why location is needed
3. Request `requestWhenInUseAuthorization`
4. If denied → show settings redirect dialog
5. Check for `reducedAccuracy` (iOS 14+) → request `requestTemporaryFullAccuracyAuthorization`

**Rationale**:
- "When In Use" is less intrusive and more likely to be granted
- Pre-permission dialog improves acceptance rate
- Full accuracy is required for route validation (approximate won't work)

### 8. iOS Info.plist Requirements

**Required entries**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Promoruta needs your location to track your route during campaign execution and validate completed work.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Promoruta needs continuous location access to track your route even when the app is in the background.</string>

<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>CampaignTracking</key>
  <string>Precise location is required to accurately track your campaign route for payment verification.</string>
</dict>
```

**Rationale**: Apple requires clear, specific usage descriptions. Vague descriptions lead to App Store rejection.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │ ActiveCampaignMapView│    │ CampaignExecutionControls  │ │
│  │ (Mapbox + Location) │    │ (Start/Pause/Complete)      │ │
│  └──────────┬──────────┘    └──────────────┬──────────────┘ │
│             │                              │                 │
│             ▼                              ▼                 │
│  ┌──────────────────────────────────────────────────────────┐│
│  │            CampaignExecutionNotifier (Riverpod)          ││
│  │  - Manages execution state                               ││
│  │  - Coordinates location service and sync                 ││
│  └──────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │ StartCampaignExec   │    │ SyncGpsPointsUseCase        │ │
│  │ StopCampaignExec    │    │ GetPendingPointsUseCase     │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │ LocationService     │    │ GpsRepository               │ │
│  │ (Geolocator stream) │    │ (Local + Remote sync)       │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Battery drain from continuous GPS | Distance-based filtering, configurable accuracy |
| Data loss on app crash | Local database persistence before upload |
| GPS drift when stationary | Filter out points with speed < 1 m/s and distance < 5m |
| Map performance with many points | Simplify polyline using Douglas-Peucker if > 500 points |
| Permission denied by user | Clear onboarding explaining why location is required |
| **iOS: Reduced accuracy granted** | Detect and request temporary full accuracy with purpose key |
| **iOS: App suspended in background** | Show warning when backgrounding; pause tracking (v1) |
| **iOS: Location services disabled system-wide** | Detect and guide user to Settings → Privacy → Location |
| **iOS: Authorization status changes mid-execution** | Listen to authorization changes, pause if revoked |

## Migration Plan

No migration needed - this is new functionality. Existing placeholder UI will be replaced.

## Open Questions

1. **Should we show estimated route on map?** - Requires route planning API integration, can be added later
2. **Audio playback status integration?** - Out of scope for this change, but design should allow for future integration
3. **What happens if user backgrounds the app?** - For v1, show warning and pause tracking. Background tracking is future work
