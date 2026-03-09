# push-notifications-backend Specification

## Purpose
TBD - created by archiving change add-campaign-available-push-notifications. Update Purpose after archive.
## Requirements
### Requirement: Device Token Storage
The backend SHALL store and maintain a valid FCM device token per user so that push
notifications can be addressed to individual devices.

#### Scenario: Token stored on first registration
- **WHEN** the mobile app sends `PUT /users/me/device-token` with a valid token string
- **AND** the user is authenticated
- **THEN** the backend persists the token on the user record (`users.fcm_token`)
- **AND** returns HTTP 200

#### Scenario: Token updated on refresh
- **WHEN** the mobile app sends `PUT /users/me/device-token` with a new token
- **AND** the user already has a stored token
- **THEN** the backend overwrites the previous token with the new one
- **AND** the old token is no longer stored

#### Scenario: Unauthenticated request rejected
- **WHEN** `PUT /users/me/device-token` is called without a valid bearer token
- **THEN** the backend returns HTTP 401

#### Scenario: Missing token field rejected
- **WHEN** `PUT /users/me/device-token` is called with an empty or missing `token` field
- **THEN** the backend returns HTTP 422 with a validation error message

---

### Requirement: New Campaign Notification Dispatch
The backend SHALL send a push notification to all eligible promoters immediately after
an advertiser successfully publishes a new campaign.

#### Scenario: Notifications sent to eligible promoters
- **WHEN** an advertiser creates a campaign and its status becomes `created`
- **THEN** the backend queries promoters with a non-null `fcm_token` and active status
- **AND** sends a multicast FCM message to all resolved tokens via the FCM HTTP v1 API
- **AND** the FCM payload includes the `notification` block (title + body) and a `data` block with `type=new_campaign` and `campaignId`

#### Scenario: No eligible promoters
- **WHEN** a campaign is published but no promoter has a registered FCM token
- **THEN** the backend skips the FCM call gracefully
- **AND** campaign creation still succeeds (notification failure is non-blocking)

#### Scenario: FCM API call fails
- **WHEN** the FCM HTTP v1 API returns an error (network timeout, quota exceeded, etc.)
- **THEN** the backend logs the error for observability
- **AND** campaign creation still succeeds (notification failure does not roll back the campaign)

---

### Requirement: Stale Token Cleanup
The backend SHALL remove FCM tokens that are reported as invalid by the FCM API to
prevent accumulation of dead tokens.

#### Scenario: FCM returns UNREGISTERED error for a token
- **WHEN** the FCM multicast response includes a token marked as `UNREGISTERED` or `INVALID_ARGUMENT`
- **THEN** the backend sets `fcm_token = null` on the corresponding user record
- **AND** the cleaned token is not used in future notification sends

---

### Requirement: FCM Payload Contract
The backend SHALL produce FCM messages conforming to the agreed payload schema so the
mobile app can parse and navigate correctly.

#### Scenario: Correct notification payload structure
- **WHEN** the backend sends a new-campaign FCM message
- **THEN** the payload `notification.title` is "Nueva campaña disponible"
- **AND** the payload `notification.body` contains the campaign title
- **AND** the payload `data.type` equals `"new_campaign"`
- **AND** the payload `data.campaignId` equals the campaign's ID as a string

#### Scenario: Android channel targeting
- **WHEN** the FCM message is destined for an Android device
- **THEN** the `android.notification.channel_id` field is set to `"campaign_alerts"`

---

### Requirement: Firebase Service Account Configuration
The backend SHALL authenticate to the FCM HTTP v1 API using a Google service account
so that notification sends are authorised.

#### Scenario: Service account credentials loaded at boot
- **WHEN** the Laravel application boots
- **THEN** the `kreait/firebase-php` SDK loads credentials from the path defined in `config/firebase.php`
- **AND** no FCM call is attempted if credentials are missing (fail-fast with logged error)

#### Scenario: Credentials file excluded from version control
- **WHEN** the repository is inspected
- **THEN** the service account JSON file is listed in `.gitignore`
- **AND** is not committed to source control

