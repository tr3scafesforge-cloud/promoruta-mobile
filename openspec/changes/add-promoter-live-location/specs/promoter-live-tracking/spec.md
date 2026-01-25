# Promoter Live Location Tracking

Real-time GPS tracking for promoters during campaign execution.

## ADDED Requirements

### Requirement: Location Tracking Service

The system SHALL provide a location tracking service that collects GPS coordinates during active campaign execution.

#### Scenario: Start location tracking
- **WHEN** promoter starts campaign execution
- **THEN** the system requests location permission if not granted
- **AND** begins collecting GPS coordinates at configured intervals
- **AND** stores coordinates locally with timestamp, speed, and accuracy

#### Scenario: Distance-based updates
- **WHEN** promoter moves more than 10 meters from last recorded position
- **THEN** a new GPS coordinate is recorded
- **AND** the polyline on the map is updated

#### Scenario: Time-based fallback
- **WHEN** 30 seconds elapse without a distance-based update
- **THEN** the current position is recorded regardless of movement
- **AND** this ensures stationary periods are captured

#### Scenario: Stop location tracking
- **WHEN** promoter completes or cancels campaign execution
- **THEN** location tracking stops
- **AND** final coordinates are synced to backend
- **AND** location resources are released

### Requirement: iOS Location Permission Handling

The system SHALL handle iOS-specific location permission requirements for campaign tracking.

#### Scenario: Request When In Use permission on iOS
- **WHEN** promoter starts campaign execution on iOS
- **AND** location permission is not determined
- **THEN** a pre-permission dialog explains why location is needed
- **AND** the system requests "When In Use" authorization
- **AND** tracking begins if permission is granted

#### Scenario: Handle reduced accuracy on iOS 14+
- **WHEN** iOS user grants location permission with reduced accuracy
- **THEN** the system detects approximate location mode
- **AND** requests temporary full accuracy with purpose key "CampaignTracking"
- **AND** explains that precise location is required for route validation

#### Scenario: Handle permission denied on iOS
- **WHEN** iOS user denies location permission
- **THEN** campaign execution cannot start
- **AND** a dialog explains location is required for campaign tracking
- **AND** provides a button to open iOS Settings app

#### Scenario: Handle permission revoked during execution on iOS
- **WHEN** iOS user revokes location permission during active campaign
- **THEN** the system detects authorization status change
- **AND** pauses campaign execution
- **AND** shows alert explaining tracking has stopped
- **AND** prompts user to restore permission in Settings

#### Scenario: Show location indicator on iOS
- **WHEN** campaign execution is active on iOS
- **THEN** the blue location indicator appears in the status bar
- **AND** user can see the app is using their location

### Requirement: Single Active Campaign Constraint

The system SHALL enforce that a promoter can only execute one campaign at a time.

#### Scenario: Attempt to start campaign while another is active
- **WHEN** promoter attempts to start a new campaign
- **AND** another campaign is currently in execution (active or paused)
- **THEN** the system prevents starting the new campaign
- **AND** displays a message indicating another campaign is in progress
- **AND** prompts the promoter to complete or cancel the active campaign first

#### Scenario: Start campaign when no active campaign
- **WHEN** promoter taps "Start" on an assigned campaign
- **AND** no other campaign is currently in execution
- **AND** location permission is granted
- **THEN** execution starts successfully
- **AND** the new campaign becomes the active campaign

### Requirement: Campaign Execution State Management

The system SHALL manage campaign execution state throughout the promoter's session.

#### Scenario: Start campaign execution
- **WHEN** promoter taps "Start" on an assigned campaign
- **AND** no other campaign is currently in execution
- **AND** location permission is granted
- **THEN** execution status changes to "active"
- **AND** GPS tracking begins
- **AND** start time is recorded
- **AND** campaign audio is loaded and ready to play

#### Scenario: Pause campaign execution
- **WHEN** promoter taps "Pause" during active execution
- **THEN** execution status changes to "paused"
- **AND** GPS tracking is suspended
- **AND** elapsed time stops counting

#### Scenario: Resume campaign execution
- **WHEN** promoter taps "Resume" while paused
- **THEN** execution status changes to "active"
- **AND** GPS tracking resumes
- **AND** elapsed time continues from paused duration

#### Scenario: Complete campaign execution
- **WHEN** promoter taps "Complete" during active or paused execution
- **THEN** execution status changes to "completed"
- **AND** GPS tracking stops
- **AND** all pending GPS points are synced
- **AND** campaign completion is reported to backend

#### Scenario: Persist execution state
- **WHEN** app is restarted during active execution
- **THEN** the previous execution state is restored
- **AND** tracking resumes automatically if status was active

### Requirement: GPS Data Synchronization

The system SHALL periodically sync collected GPS coordinates to the backend.

#### Scenario: Periodic batch sync
- **WHEN** 60 seconds elapse during active execution
- **OR** 20 GPS points accumulate
- **THEN** pending points are uploaded to backend in a batch
- **AND** successfully synced points are marked as synced locally

#### Scenario: Offline resilience
- **WHEN** network is unavailable during sync attempt
- **THEN** points remain in local storage
- **AND** sync is retried when network becomes available

#### Scenario: Idempotent uploads
- **WHEN** a batch is uploaded with idempotency keys
- **AND** the same batch is sent again (retry scenario)
- **THEN** the backend returns existing records without duplication

### Requirement: Live Map Display

The system SHALL display a real-time map showing promoter location and traveled route.

#### Scenario: Show current location
- **WHEN** active campaign map view is displayed
- **THEN** a marker shows the promoter's current GPS position
- **AND** the marker updates as new coordinates arrive

#### Scenario: Draw traveled route
- **WHEN** GPS coordinates are collected during execution
- **THEN** a polyline is drawn on the map connecting all points
- **AND** new segments are appended as the promoter moves

#### Scenario: Center on location
- **WHEN** promoter taps the center button
- **THEN** the map camera animates to current location
- **AND** appropriate zoom level is applied

### Requirement: Execution Progress Display

The system SHALL show execution progress metrics during campaign execution.

#### Scenario: Display elapsed time
- **WHEN** campaign execution is active
- **THEN** elapsed time is displayed in HH:MM:SS format
- **AND** timer updates every second

#### Scenario: Display distance traveled
- **WHEN** campaign execution is active
- **THEN** total distance traveled is displayed in kilometers
- **AND** distance updates as new GPS points are recorded

#### Scenario: Display status indicator
- **WHEN** viewing active campaign
- **THEN** current execution status is shown (Active/Paused)
- **AND** status badge uses appropriate color (green for active, yellow for paused)

### Requirement: Campaign Audio Playback

The system SHALL allow promoters to play the campaign's audio file during execution.

#### Scenario: Load campaign audio on execution start
- **WHEN** campaign execution starts
- **THEN** the system loads the campaign's audio file (provided by advertiser)
- **AND** the audio player is initialized and ready
- **AND** audio controls are displayed in the map view

#### Scenario: Play campaign audio
- **WHEN** promoter taps "Play" on the audio player
- **THEN** the campaign audio begins playing
- **AND** the play button changes to a pause button
- **AND** the progress bar shows playback position

#### Scenario: Pause campaign audio
- **WHEN** promoter taps "Pause" on the audio player
- **THEN** the audio playback pauses
- **AND** the pause button changes to a play button
- **AND** the playback position is preserved

#### Scenario: Seek audio position
- **WHEN** promoter drags the progress bar
- **THEN** the audio playback seeks to the selected position
- **AND** playback continues from the new position if was playing

#### Scenario: Replay campaign audio
- **WHEN** audio playback completes
- **THEN** the progress bar resets to the beginning
- **AND** the promoter can tap "Play" to replay the audio
- **AND** audio can be replayed unlimited times during campaign

#### Scenario: Audio independent of GPS tracking state
- **WHEN** campaign execution is paused
- **THEN** audio playback can continue or be started
- **AND** audio is not affected by GPS tracking pause
- **RATIONALE** promoter stopped at traffic light may still want to play audio

#### Scenario: Audio stops on campaign completion
- **WHEN** promoter completes the campaign
- **THEN** audio playback stops
- **AND** audio player resources are released
