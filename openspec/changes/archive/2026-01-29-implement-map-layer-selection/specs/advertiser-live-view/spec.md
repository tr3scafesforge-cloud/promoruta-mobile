# advertiser-live-view Spec Delta

This change implements the existing "Map layer toggle" scenario that is already defined in the spec.

## MODIFIED Requirements

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
