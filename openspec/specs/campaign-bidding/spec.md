# campaign-bidding Specification

## Purpose
TBD - created by archiving change add-campaign-bidding. Update Purpose after archive.
## Requirements
### Requirement: Promoter Bid Submission
The system SHALL allow promoters to submit a bid for campaigns in `created` status.

#### Scenario: Submit bid successfully
- **WHEN** promoter submits a bid with price and optional message
- **AND** the campaign status is `created`
- **THEN** the bid is created with status `pending`
- **AND** the promoter sees the bid status on the campaign detail screen

#### Scenario: Reject duplicate or late bid
- **WHEN** promoter submits a bid for a campaign where they already have a bid
- **OR** the bid deadline has passed
- **THEN** the system rejects the bid
- **AND** the promoter sees a validation error message

### Requirement: Multi-Promoter Bidding
The system SHALL allow multiple promoters to submit bids for the same campaign while the campaign status is `created`.

#### Scenario: Multiple promoters bid on one campaign
- **WHEN** two or more different promoters submit bids on the same campaign
- **AND** the campaign status is `created`
- **THEN** all bids are accepted as `pending`
- **AND** the advertiser can view all submitted bids

### Requirement: Bid Visibility and Management
The system SHALL present bid data according to role and allow promoters to update or withdraw their own bids while bidding is open.

#### Scenario: Advertiser views all bids
- **WHEN** advertiser opens a campaign's bids list
- **THEN** all bids for that campaign are displayed
- **AND** each bid includes promoter profile and bid status

#### Scenario: Promoter views only their bid
- **WHEN** promoter opens a campaign's bids list
- **THEN** only the promoter's own bid is displayed

#### Scenario: Update or withdraw own bid
- **WHEN** promoter edits or withdraws their bid
- **AND** the campaign status is `created`
- **AND** the bid status is `pending`
- **THEN** the update or withdrawal is accepted
- **AND** the bid status reflects the change

### Requirement: Bid Acceptance and Payment Initiation
The system SHALL allow advertisers to accept a bid and initiate payment for the campaign.

#### Scenario: Accept a bid
- **WHEN** advertiser accepts a specific bid
- **THEN** the campaign status becomes `accepted`
- **AND** the accepted bid status becomes `accepted`
- **AND** all other pending bids become `rejected`

#### Scenario: Payment pending after acceptance
- **WHEN** a bid is accepted
- **THEN** a payment record is created with status `pending`
- **AND** the response includes a `checkout_url` if available

### Requirement: Payment Confirmation Gate
The system SHALL block campaign execution start until payment is confirmed as `paid`.

#### Scenario: Start blocked when payment is pending
- **WHEN** the assigned promoter attempts to start a campaign
- **AND** the campaign payment status is `pending`
- **THEN** the system prevents execution start
- **AND** the UI shows "waiting for payment" state

#### Scenario: Start allowed after payment confirmation
- **WHEN** payment status becomes `paid`
- **THEN** the assigned promoter can start execution
- **AND** the campaign status transitions to `in_progress`

#### Scenario: Manual payment confirmation
- **WHEN** advertiser triggers manual payment confirmation
- **THEN** the payment status becomes `paid` if the backend validates it
- **AND** the campaign becomes eligible to start

### Requirement: Campaign Status Labels
The system SHALL display user-facing labels derived from campaign and payment status.

#### Scenario: Accepted with payment pending
- **WHEN** campaign status is `accepted` and payment status is `pending`
- **THEN** the UI label shows "Offer accepted, waiting for payment"

#### Scenario: Accepted with payment paid
- **WHEN** campaign status is `accepted` and payment status is `paid`
- **THEN** the UI label shows "Ready to start"

#### Scenario: Terminal statuses
- **WHEN** campaign status is `completed`, `cancelled`, or `expired`
- **THEN** the UI label reflects the terminal status

### Requirement: Campaign Detail Polling
The system SHALL poll campaign detail and bids while bidding or acceptance is in progress.

#### Scenario: Poll during bidding
- **WHEN** campaign status is `created` or `accepted`
- **THEN** the campaign detail screen refreshes every 15-30 seconds

#### Scenario: Slow polling during execution
- **WHEN** campaign status is `in_progress`
- **THEN** polling slows to every 30-60 seconds
- **AND** polling stops when the campaign is `completed`, `cancelled`, or `expired`

