# Change: Implement Live Location Tracking for Promoters During Campaign Execution

## Why

Promoruta's core value proposition is **GPS traceability and execution validation** for sound advertising campaigns. Currently, the mobile app has placeholder UI and basic GPS infrastructure but lacks actual live location tracking during campaign execution. This feature is essential for:

- Validating that promoters complete their assigned routes
- Providing real-time visibility to advertisers
- Calculating accurate distance traveled for payment verification
- Building trust through transparent execution proof

## What Changes

### Mobile App (Flutter)

1. **Location Tracking Service**
   - Foreground service for continuous GPS tracking during active campaigns
   - Configurable update intervals (accuracy vs battery trade-off)
   - Automatic start/stop when campaign execution begins/ends

2. **Live Map Integration**
   - Replace placeholder map with Mapbox showing real-time promoter position
   - Draw traveled route as polyline
   - Show campaign zone/boundaries if defined

3. **Campaign Execution Flow**
   - Start campaign execution with GPS tracking enabled
   - **Single active campaign constraint**: Promoter can only execute one campaign at a time
   - Pause/Resume functionality
   - Complete campaign and stop tracking

4. **Campaign Audio Playback**
   - Play the campaign's audio file during execution (audio provided by advertiser)
   - Audio player controls (play/pause, progress indicator)
   - Audio can be replayed multiple times during campaign execution

5. **GPS Data Synchronization**
   - Batch upload GPS coordinates to backend periodically
   - Local storage for offline resilience
   - Idempotency keys to prevent duplicate uploads

6. **State Management**
   - Track campaign execution state (idle, active, paused)
   - Persist state across app restarts
   - Handle location permission requests
   - Prevent starting a new campaign while another is in progress

### Backend (Already Implemented)

The backend already supports:
- `POST /campaigns/{id}/gps-tracks` - Batch GPS coordinate upload with idempotency
- `GET /campaigns/{id}/gps-tracks` - Retrieve GPS tracks for a campaign
- Distance calculation via Haversine formula

## Impact

- **Affected specs**: New capability `promoter-live-tracking`
- **Affected code**:
  - `lib/features/promotor/gps_tracking/` - Enhance existing infrastructure
  - `lib/features/promotor/presentation/pages/active_campaign_map_view.dart` - Replace placeholder
  - `lib/features/promotor/route_execution/` - New campaign execution logic
  - `lib/shared/services/` - New location service
- **Dependencies**: Uses existing `geolocator`, `mapbox_maps_flutter` packages
- **Permissions**: Requires location permissions (already configured)
