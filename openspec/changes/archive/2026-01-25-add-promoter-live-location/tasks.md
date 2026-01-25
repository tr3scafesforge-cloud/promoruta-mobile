# Implementation Tasks

## 1. Location Service Foundation

- [x] 1.1 Create `LocationService` class in `lib/shared/services/location_service.dart`
  - Stream-based location updates using Geolocator
  - Configurable accuracy and distance filter
  - Permission request handling

- [x] 1.2 Create Riverpod provider for `LocationService`
  - Add to `lib/shared/providers/providers.dart`
  - Expose location stream as `StreamProvider`

- [x] 1.3 Add location permission request flow (Android)
  - Check and request permissions before starting tracking
  - Handle denied/permanently denied states with user guidance

- [x] 1.4 Add iOS-specific location permission flow
  - Show pre-permission dialog before requesting authorization
  - Request "When In Use" authorization
  - Detect reduced accuracy and request temporary full accuracy
  - Handle authorization status changes via stream
  - Guide user to Settings when permission denied

- [x] 1.5 Configure iOS Info.plist entries
  - Add NSLocationWhenInUseUsageDescription
  - Add NSLocationAlwaysAndWhenInUseUsageDescription (for future)
  - Add NSLocationTemporaryUsageDescriptionDictionary with CampaignTracking key

- [x] 1.6 Implement iOS-specific location settings
  - Use AppleSettings with activityType.automotiveNavigation
  - Configure pauseLocationUpdatesAutomatically: false
  - Enable showBackgroundLocationIndicator: true

## 2. Campaign Execution State Management

- [x] 2.1 Create `CampaignExecutionState` and `CampaignExecutionStatus` models
  - Define state structure: status, campaignId, pendingPoints, startedAt, distanceTraveled

- [x] 2.2 Create `CampaignExecutionNotifier` (StateNotifier)
  - Methods: startExecution, pauseExecution, resumeExecution, completeExecution
  - **Enforce single active campaign**: reject startExecution if another campaign is active
  - Handle location stream subscription lifecycle
  - Accumulate GPS points and trigger sync

- [x] 2.3 Add Riverpod provider for campaign execution state
  - `campaignExecutionProvider` as StateNotifierProvider

## 3. GPS Data Persistence & Sync

- [x] 3.1 Update `GpsPoints` table in Drift database
  - Add `syncedAt` nullable column for tracking upload status
  - Run migration (schema version bump)

- [x] 3.2 Update `GpsLocalDataSource`
  - Add method to get unsyced points
  - Add method to mark points as synced

- [x] 3.3 Create `SyncGpsPointsUseCase`
  - Fetch unsynced points from local DB
  - Upload in batches to backend
  - Mark as synced on success
  - Handle idempotency keys

- [x] 3.4 Implement periodic sync timer in `CampaignExecutionNotifier`
  - Trigger sync every 60 seconds during active execution
  - Also sync when batch reaches 20 points

## 4. Live Map UI Implementation

- [x] 4.1 Update `ActiveCampaignMapView` with real Mapbox map
  - Initialize MapboxMap widget
  - Configure map style and initial camera position

- [x] 4.2 Implement current location marker
  - Use `PointAnnotationManager` to show promoter location
  - Update marker position on each location update

- [x] 4.3 Implement route polyline
  - Use `PolylineAnnotationManager` for traveled path
  - Append new coordinates as they arrive
  - Style with appropriate color and width

- [x] 4.4 Add map controls
  - Center on current location button
  - Zoom controls (optional)

## 5. Campaign Execution Controls UI

- [x] 5.1 Update bottom controls in `ActiveCampaignMapView`
  - Start/Pause/Resume button based on execution state
  - Complete campaign button
  - Show elapsed time and distance traveled

- [x] 5.2 Create campaign start confirmation dialog
  - Explain GPS tracking will begin
  - Request location permission if not granted

- [x] 5.3 Create campaign completion confirmation dialog
  - Show summary: duration, distance, GPS points collected
  - Confirm before ending execution

## 6. Campaign Audio Playback

- [x] 6.1 Add `just_audio` dependency to pubspec.yaml
  - Audio player package with streaming and caching support

- [x] 6.2 Create `CampaignAudioService` class
  - Load audio from campaign URL (audio_file_path from advertiser)
  - Play/Pause/Seek methods
  - Expose position and duration streams

- [x] 6.3 Add Riverpod provider for audio service
  - `campaignAudioProvider` linked to active campaign
  - Dispose player on campaign completion

- [x] 6.4 Implement audio player UI in `ActiveCampaignMapView`
  - Play/Pause button
  - Progress bar (Slider) with seek functionality
  - Current time / Total duration display
  - Style consistent with app theme

- [x] 6.5 Integrate audio service with campaign execution
  - Load audio when campaign starts
  - Stop and release audio on campaign completion
  - Audio state independent of GPS tracking state

## 7. Integration & Polish

- [x] 7.1 Connect `PromoterActivePage` to real campaign data
  - Replace mock `ActiveCampaign` with API data
  - Show real execution status
  - **Disable start button if another campaign is active**

- [x] 7.2 Add execution state persistence
  - Save active campaign ID to SharedPreferences
  - Restore execution state on app restart
  - Restore audio state (position) if needed

- [x] 7.3 Handle edge cases
  - Location permission denied during execution
  - App backgrounded during tracking (show warning)
  - Network errors during sync (retry with backoff)
  - **Prevent starting new campaign while one is in progress** (enforced in CampaignExecutionNotifier)
  - Audio loading failure (show error, allow retry)

- [x] 7.4 Add localization strings for new UI elements
  - Start/Pause/Resume/Complete labels
  - Permission dialogs
  - Error messages
  - **Audio player labels (Play/Pause, loading, error)**
  - **"Campaign already in progress" message**

## 8. Testing

- [x] 8.1 Unit tests for `CampaignExecutionNotifier`
  - State transitions
  - Point accumulation logic
  - **Single active campaign enforcement**

- [x] 8.2 Unit tests for `SyncGpsPointsUseCase`
  - Batch upload logic
  - Idempotency handling

- [x] 8.3 Widget tests for execution controls
  - Button state based on execution status
  - **Start button disabled when campaign active**

- [x] 8.4 Unit tests for `CampaignAudioService`
  - Play/Pause state transitions
  - Position tracking

## Dependencies

- Task 1 must complete before Task 2 (location service needed for execution)
- Task 3.1 must complete before Task 3.2-3.4 (database migration first)
- Tasks 4.x and 5.x can run in parallel after Task 2
- **Task 6 (Audio) can run in parallel with Tasks 4 and 5**
- Task 7 depends on Tasks 4, 5, and 6

## Parallelizable Work

- Tasks 4.x (Map UI) and 5.x (Controls UI) can be developed in parallel
- **Task 6 (Audio) can be developed independently**
- Task 8 (Testing) can partially overlap with Task 7
