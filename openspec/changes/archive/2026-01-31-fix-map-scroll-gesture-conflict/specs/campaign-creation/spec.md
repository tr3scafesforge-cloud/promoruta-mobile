## ADDED Requirements

### Requirement: Dedicated Map Selection Screen
The campaign creation flow SHALL provide a dedicated full-screen map for selecting the coverage zone route, separate from the main form.

#### Scenario: User opens the map picker
- **WHEN** the user taps the "Seleccionar zona en el mapa" button on the create campaign form
- **THEN** the app navigates to a full-screen map picker page
- **AND** any previously selected waypoints are displayed on the map

#### Scenario: User selects waypoints and returns
- **WHEN** the user adds waypoints on the map and confirms the selection
- **THEN** the app returns to the create campaign form
- **AND** the selected waypoints and calculated route are preserved in the form state

#### Scenario: User cancels map selection
- **WHEN** the user presses the back button on the map screen without confirming
- **THEN** the app returns to the create campaign form
- **AND** any previous waypoint selection is preserved (not cleared)

### Requirement: Map Gesture Freedom
The map picker screen SHALL allow full gesture interaction without conflicts.

#### Scenario: User pans the map
- **WHEN** the user performs a pan gesture on the map
- **THEN** the map viewport moves accordingly

#### Scenario: User zooms the map
- **WHEN** the user performs a pinch-to-zoom gesture on the map
- **THEN** the map zoom level changes accordingly

#### Scenario: User taps to add waypoint
- **WHEN** the user taps on the map
- **THEN** a new waypoint is added at that location
