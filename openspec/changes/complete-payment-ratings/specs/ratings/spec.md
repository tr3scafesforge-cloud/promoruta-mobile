# Specification Delta: Ratings

## ADDED Requirements
### Requirement: Bidirectional Campaign Rating
Users SHALL be able to rate both sides of a completed campaign transaction.

#### Scenario: Advertiser rates promoter
- **WHEN** a promoter completes a campaign
- **THEN** advertiser receives notification and is prompted to rate the promoter's execution quality

#### Scenario: Promoter rates advertiser
- **WHEN** a promoter completes a campaign
- **THEN** promoter is prompted to rate the advertiser's campaign details and communication

#### Scenario: Rating submission
- **WHEN** user completes a rating (1-5 stars + optional comment)
- **THEN** rating is submitted to backend and persisted locally

#### Scenario: Duplicate prevention
- **WHEN** user attempts to rate the same campaign twice
- **THEN** system prevents submission and shows message that rating already submitted

### Requirement: User Rating Profile
Users SHALL have visible rating information on their profile.

#### Scenario: Average rating display
- **WHEN** viewing a user's profile
- **THEN** average rating (0-5 stars) is prominently displayed

#### Scenario: Rating count display
- **WHEN** viewing a user's profile
- **THEN** total number of ratings received is shown

#### Scenario: Recent ratings list
- **WHEN** viewing a user's profile ratings section
- **THEN** recent ratings with stars, comments, and reviewer name are listed (up to 10)

#### Scenario: Rating badges
- **WHEN** user's average rating reaches milestones (3.5★, 4.0★, 4.5★)
- **THEN** corresponding badge appears on user profile

### Requirement: Rating History and Analytics
Users SHALL be able to view their rating history and statistics.

#### Scenario: Rating history page
- **WHEN** user navigates to their Rating History
- **THEN** all ratings they received are displayed with date, stars, and comment

#### Scenario: Offline rating history
- **WHEN** user views rating history without network connection
- **THEN** cached ratings are displayed

### Requirement: Rating Notifications
Users SHALL be notified when they receive new ratings.

#### Scenario: Rating notification
- **WHEN** another user submits a rating for current user
- **THEN** notification is queued (assuming backend push notification support)

#### Scenario: Rating list updates
- **WHEN** new ratings sync from backend
- **THEN** user's profile shows updated average and review list

### Requirement: Rating Offline Support
Ratings SHALL function in offline mode with sync on reconnection.

#### Scenario: Submit rating offline
- **WHEN** user attempts to submit rating without network
- **THEN** rating is cached locally and queued for sync

#### Scenario: Rating sync on reconnect
- **WHEN** network connection is restored
- **THEN** pending ratings are synced to backend
