# Specification Delta: Payments

## ADDED Requirements
### Requirement: Payment Processing
The system SHALL provide a complete payment workflow for campaigns.

#### Scenario: Payment method selection
- **WHEN** user submits a campaign and initiates payment
- **THEN** user is shown payment method options (credit card, debit card, wallet)

#### Scenario: Payment processing
- **WHEN** user selects a payment method and confirms
- **THEN** payment request is sent to backend and user sees progress indicator

#### Scenario: Payment success
- **WHEN** payment is successfully processed
- **THEN** campaign transitions to `pending_approval` state and user sees confirmation with receipt

#### Scenario: Payment failure
- **WHEN** payment fails (declined card, network error, etc.)
- **THEN** user sees error message and option to retry or select different method

### Requirement: Payment History
The system SHALL provide users access to their payment transaction history.

#### Scenario: View payment history
- **WHEN** user navigates to Payment History page
- **THEN** all past campaign payments are displayed with date, amount, campaign name, status

#### Scenario: Payment details
- **WHEN** user taps a transaction in history
- **THEN** transaction details including receipt, payment method, timestamp are shown

#### Scenario: Offline payment history
- **WHEN** user views payment history without network connection
- **THEN** cached payment history is displayed; new payments shown as pending sync

### Requirement: Payment Status Tracking
The system SHALL track and display the status of all payments.

#### Scenario: Payment statuses
- **WHEN** payment is created
- **THEN** status is one of: `pending`, `processing`, `completed`, `failed`, `refunded`

#### Scenario: Status updates reflected
- **WHEN** payment status changes on backend
- **THEN** local cache is updated on next sync and UI reflects current status

### Requirement: Campaign Payment Requirement
Campaigns SHALL require payment before being broadcast.

#### Scenario: Campaign creation requires payment
- **WHEN** campaign is submitted for approval
- **THEN** payment step is required before campaign enters approval queue

#### Scenario: No broadcast without payment
- **WHEN** campaign lacks associated payment record or payment failed
- **THEN** campaign cannot transition to `active` state
