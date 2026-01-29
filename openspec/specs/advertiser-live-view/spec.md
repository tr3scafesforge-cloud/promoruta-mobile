# advertiser-live-view Specification

## Purpose
TBD - created by archiving change add-advertiser-live-view. Update Purpose after archive.
## Requirements
### Requirement: Live Campaign Dashboard

The system SHALL provide advertisers with a real-time dashboard showing all their active campaigns on a map.

#### Scenario: Display active campaigns on map
- **WHEN** advertiser navigates to the Live tab
- **AND** the advertiser has one or more campaigns currently being executed
- **THEN** the map displays all active campaigns with route polylines
- **AND** promoter markers show current location for each campaign
- **AND** coverage zones are displayed as semi-transparent overlays

#### Scenario: No active campaigns
- **WHEN** advertiser navigates to the Live tab
- **AND** no campaigns are currently being executed
- **THEN** the map shows an empty state with a helpful message
- **AND** a button suggests creating a new campaign or viewing pending campaigns

#### Scenario: Campaign list in bottom sheet
- **WHEN** advertiser is on the Live tab
- **THEN** a draggable bottom sheet shows a list of active campaigns
- **AND** each campaign shows promoter name, location, and status
- **AND** the sheet can be expanded to show more details

### Requirement: Multi-Campaign Selection

The system SHALL allow advertisers to focus on individual campaigns when multiple are active.

#### Scenario: Select campaign from list
- **WHEN** advertiser taps on a campaign in the bottom sheet list
- **THEN** the map zooms and centers on that campaign's promoter
- **AND** the campaign is highlighted as selected
- **AND** detailed metrics are displayed for the selected campaign

#### Scenario: Filter campaigns by status
- **WHEN** advertiser taps a filter chip (Active, Pending, No Signal)
- **THEN** the campaign list shows only campaigns matching the filter
- **AND** the map markers update to show only filtered campaigns

#### Scenario: Follow mode for selected campaign
- **WHEN** advertiser enables follow mode for a selected campaign
- **THEN** the map automatically pans to keep the promoter centered
- **AND** the view updates as new location data arrives
- **AND** a button allows disabling follow mode

### Requirement: Promoter Live Location Display

The system SHALL display real-time location of promoters executing campaigns.

#### Scenario: Show promoter location marker
- **WHEN** a campaign is actively being executed
- **THEN** a marker shows the promoter's current GPS position
- **AND** the marker includes the promoter's name or initials
- **AND** the marker color indicates status (green for active, yellow for paused)

#### Scenario: Location update via polling
- **WHEN** the Live tab is active
- **THEN** the system polls for location updates every 10 seconds
- **AND** promoter markers are updated with new positions
- **AND** a "last updated" timestamp is displayed

#### Scenario: Stale location data
- **WHEN** promoter location has not updated for more than 2 minutes
- **THEN** the marker is displayed with a "stale" visual indicator (grayed out)
- **AND** a warning icon appears next to the promoter in the list

#### Scenario: Promoter without signal
- **WHEN** promoter location has not updated for more than 5 minutes
- **THEN** the promoter is marked as "No Signal" in the list
- **AND** an alert is generated for the advertiser

### Requirement: Campaign Progress Metrics

The system SHALL display execution progress for active campaigns.

#### Scenario: Display distance traveled
- **WHEN** viewing an active campaign
- **THEN** the distance traveled is displayed in kilometers
- **AND** the distance updates as new GPS data is received

#### Scenario: Display elapsed time
- **WHEN** viewing an active campaign
- **THEN** the elapsed execution time is displayed in HH:MM format
- **AND** the timer updates in real-time

#### Scenario: Display execution status
- **WHEN** viewing an active campaign
- **THEN** the current status is displayed (Active, Paused)
- **AND** a status badge uses appropriate color (green, yellow)

#### Scenario: Display route on map
- **WHEN** viewing an active campaign
- **THEN** the planned route is displayed as a polyline on the map
- **AND** the traveled portion is highlighted in a different color
- **AND** the remaining route is shown in a lighter color

### Requirement: Campaign Execution Alerts

The system SHALL notify advertisers of campaign execution events.

#### Scenario: Alert when campaign starts
- **WHEN** a promoter starts executing an advertiser's campaign
- **THEN** an alert is added to the alerts list
- **AND** the alert shows "Campaign started" with promoter name and time
- **AND** the unread alert count is incremented

#### Scenario: Alert when campaign pauses
- **WHEN** a promoter pauses campaign execution
- **THEN** an alert is added with "Campaign paused" message
- **AND** the alert includes duration paused after resumption

#### Scenario: Alert when campaign completes
- **WHEN** a promoter completes campaign execution
- **THEN** an alert is added with "Campaign completed" message
- **AND** the alert includes total distance and time

#### Scenario: Alert for no signal
- **WHEN** promoter location has not updated for 5+ minutes during active execution
- **THEN** an alert is generated with "No signal from promoter" message
- **AND** the alert uses a warning visual style

#### Scenario: View alerts list
- **WHEN** advertiser taps the Alerts tab in the bottom sheet
- **THEN** a list of recent alerts is displayed
- **AND** alerts are sorted by time (newest first)
- **AND** unread alerts are visually distinguished

#### Scenario: Clear alert badge
- **WHEN** advertiser views the alerts list
- **THEN** the unread alert count is cleared
- **AND** viewed alerts are marked as read

### Requirement: Map Controls

The system SHALL provide standard map controls for the live view.

#### Scenario: Center on current location
- **WHEN** advertiser taps the "my location" button
- **THEN** the map centers on the advertiser's current GPS position
- **AND** an appropriate zoom level is applied

#### Scenario: Zoom controls
- **WHEN** advertiser uses zoom buttons or pinch gestures
- **THEN** the map zooms in or out accordingly
- **AND** zoom level persists during polling updates

#### Scenario: Map layer toggle
- **WHEN** advertiser taps the layers button
- **THEN** a bottom sheet appears with layer options (Streets, Satellite, Outdoors)
- **AND** the currently selected style is highlighted
- **WHEN** advertiser selects a different style
- **THEN** the map immediately updates to the selected style
- **AND** the preference is persisted for future sessions

### Requirement: Offline Handling

The system SHALL handle network connectivity issues gracefully.

#### Scenario: Network unavailable
- **WHEN** network connection is lost while on the Live tab
- **THEN** a banner indicates "No connection"
- **AND** the last known positions remain displayed
- **AND** polling automatically resumes when connection returns

#### Scenario: API error
- **WHEN** the live campaigns API returns an error
- **THEN** an error message is displayed to the user
- **AND** a retry button is provided
- **AND** existing data remains visible if available

