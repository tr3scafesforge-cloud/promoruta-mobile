## ADDED Requirements
### Requirement: Promoter Home Active Campaign Summary
The system SHALL show the promoter's current active campaign on the promoter home page using live data from the campaigns API.

#### Scenario: Active campaign available
- **WHEN** the promoter opens the home page
- **AND** the campaigns API returns at least one campaign assigned to the promoter with status `in_progress`
- **THEN** the home page shows an active campaign summary card populated from that response
- **AND** the card reflects the campaign title, route context, payout, and progress data derived from the campaign record

#### Scenario: No active campaign available
- **WHEN** the promoter opens the home page
- **AND** the campaigns API returns no campaigns assigned to the promoter with status `in_progress`
- **THEN** the home page does not show placeholder active campaign content
- **AND** the UI shows a no-active-campaign state instead

#### Scenario: Active campaign query fails
- **WHEN** the promoter opens the home page
- **AND** the active campaign query fails
- **THEN** the home page shows a recoverable error state for the active campaign section
- **AND** the rest of the home page remains usable
