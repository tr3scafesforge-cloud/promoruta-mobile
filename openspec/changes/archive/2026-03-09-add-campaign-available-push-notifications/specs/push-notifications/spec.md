## ADDED Requirements

### Requirement: FCM Device Token Registration
The app SHALL register the device's FCM token with the backend after every successful login
and whenever the token is refreshed by the OS.

#### Scenario: Token registered on login
- **WHEN** a promoter logs in successfully
- **THEN** the app retrieves the FCM device token
- **AND** sends it to the backend `PUT /users/me/device-token` endpoint
- **AND** the backend associates the token with the authenticated user

#### Scenario: Token refreshed by OS
- **WHEN** Firebase rotates the device token (e.g. after APNs certificate change or app restore)
- **THEN** the app detects the new token via `onTokenRefresh`
- **AND** sends the updated token to the backend
- **AND** the old token is replaced so stale tokens do not accumulate

#### Scenario: Token unavailable
- **WHEN** the device cannot retrieve an FCM token (e.g. no network, no Play Services)
- **THEN** the app logs the failure silently
- **AND** continues normal operation without crashing
- **AND** retries registration on the next app launch

---

### Requirement: Notification Permission Request
The app SHALL request push notification permission from the operating system at the
appropriate moment so that promoters can receive campaign alerts.

#### Scenario: Permission requested after first login
- **WHEN** a promoter logs in for the first time
- **AND** the OS has not yet been asked for notification permission
- **THEN** the system notification permission dialog is shown
- **AND** the result is stored so the dialog is not shown again on subsequent launches

#### Scenario: Permission already granted
- **WHEN** notification permission was previously granted
- **THEN** the app proceeds without showing the permission dialog again

#### Scenario: Permission denied
- **WHEN** the promoter denies notification permission
- **THEN** the app continues to function normally
- **AND** the promoter can grant permission later through device Settings

---

### Requirement: New Campaign Available Push Notification
The system SHALL notify eligible promoters via push notification when an advertiser
publishes a new campaign.

#### Scenario: Notification delivered while app is in background or terminated
- **WHEN** an advertiser creates and publishes a new campaign
- **AND** a promoter has notification permission granted
- **AND** the promoter's device is registered with a valid FCM token
- **THEN** the promoter's device displays a system push notification
- **AND** the notification title reads "Nueva campaña disponible" (localised)
- **AND** the notification body includes the campaign title

#### Scenario: Notification delivered while app is in foreground (Android)
- **WHEN** a new campaign notification arrives while the promoter has the app open on Android
- **THEN** a heads-up notification banner is shown via `flutter_local_notifications`
- **AND** the notification title and body match the FCM payload

#### Scenario: Notification delivered while app is in foreground (iOS)
- **WHEN** a new campaign notification arrives while the promoter has the app open on iOS
- **THEN** the notification is presented as an alert with sound and badge
- **AND** `UNUserNotificationCenter` foreground presentation options include alert, sound, and badge

---

### Requirement: Notification Tap Deep-Link
The app SHALL navigate the promoter directly to the campaign detail page when a
new-campaign notification is tapped.

#### Scenario: Tap on notification while app is in background
- **WHEN** the promoter taps the new-campaign notification
- **AND** the app is running in the background
- **THEN** the app is brought to the foreground
- **AND** navigates to `/campaigns/:campaignId` using the `campaignId` from the FCM data payload

#### Scenario: Tap on notification while app is terminated
- **WHEN** the promoter taps the new-campaign notification
- **AND** the app was not running
- **THEN** the app launches
- **AND** navigates to `/campaigns/:campaignId` after the app is fully initialised

#### Scenario: Missing or invalid campaignId in payload
- **WHEN** the FCM data payload does not contain a valid `campaignId`
- **THEN** the app navigates to the promoter home page instead
- **AND** logs a warning for observability

---

### Requirement: Background Notification Handling
The app SHALL process FCM messages received in the background or while terminated
without requiring the app to be open.

#### Scenario: Background FCM data message processed
- **WHEN** a `new_campaign` FCM data-only message is received while the app is in the background
- **THEN** a background isolate is spawned (Android) or silent push is processed (iOS)
- **AND** the notification is displayed to the promoter by the OS

#### Scenario: Terminated app receives notification
- **WHEN** a notification arrives while the app is terminated
- **THEN** the OS displays the notification from the FCM notification block
- **AND** on next launch the app checks `getInitialMessage` to handle any pending tap

---

### Requirement: Localised Notification Copy
Push notification content strings SHALL be available in all supported languages
(Spanish, English, Portuguese) so the OS can render them in the device locale.

#### Scenario: Notification copy in Spanish
- **WHEN** the device locale is Spanish
- **THEN** the notification title is "Nueva campaña disponible"
- **AND** the body template is "{{campaignTitle}} cerca de ti"

#### Scenario: Notification copy in English
- **WHEN** the device locale is English
- **THEN** the notification title is "New campaign available"
- **AND** the body template is "{{campaignTitle}} near you"

#### Scenario: Notification copy in Portuguese
- **WHEN** the device locale is Portuguese
- **THEN** the notification title is "Nova campanha disponível"
- **AND** the body template is "{{campaignTitle}} perto de você"

---

### Requirement: Android Notification Channel
The app SHALL declare a dedicated notification channel for campaign alerts on Android
(API 26+) so promoters can control the sound and importance level independently.

#### Scenario: Channel created on first launch
- **WHEN** the app runs for the first time on Android API 26 or above
- **THEN** a notification channel with id `campaign_alerts` is created
- **AND** the channel importance is set to HIGH (heads-up behaviour)
- **AND** the channel name is "Alertas de campañas" (localised)

#### Scenario: Notification routed to channel
- **WHEN** a new-campaign FCM notification is delivered on Android
- **THEN** the notification is displayed using the `campaign_alerts` channel
- **AND** the system sound and vibration settings of that channel are respected
