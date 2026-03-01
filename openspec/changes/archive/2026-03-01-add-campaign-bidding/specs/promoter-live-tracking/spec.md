## MODIFIED Requirements
### Requirement: Campaign Execution State Management

The system SHALL manage campaign execution state throughout the promoter's session, including payment-gated start.

#### Scenario: Start campaign execution
- **WHEN** promoter taps "Start" on an assigned campaign
- **AND** the campaign status is `accepted`
- **AND** the payment status is `paid`
- **AND** no other campaign is currently in execution
- **AND** location permission is granted
- **THEN** execution status changes to "active"
- **AND** GPS tracking begins
- **AND** start time is recorded
- **AND** campaign audio is loaded and ready to play

#### Scenario: Block start when payment is pending
- **WHEN** promoter taps "Start" on an assigned campaign
- **AND** the payment status is `pending`
- **THEN** execution does not start
- **AND** the UI indicates the campaign is waiting for payment

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
