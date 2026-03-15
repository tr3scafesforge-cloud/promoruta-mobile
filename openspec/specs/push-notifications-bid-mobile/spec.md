# push-notifications-bid-mobile Specification

## Purpose
TBD - created by archiving change add-bid-placed-push-notifications. Update Purpose after archive.
## Requirements
### Requirement: Advertiser Bid Notification Routing
The mobile app SHALL route incoming FCM messages of type `bid_placed`, `bid_updated`,
and `bid_withdrawn` to the appropriate handler so that advertisers are taken directly
to the relevant campaign bids list.

#### Scenario: Notification tap while app is in background — bid placed
- **WHEN** an advertiser receives a `bid_placed` push notification
- **AND** taps it while the app is running in the background
- **THEN** the app is brought to the foreground
- **AND** navigates to the campaign bids list page for the `campaignId` in the FCM data payload

#### Scenario: Notification tap while app is terminated — bid placed
- **WHEN** an advertiser taps a `bid_placed` push notification
- **AND** the app was not running
- **THEN** the app launches
- **AND** navigates to the campaign bids list page after the app is fully initialised

#### Scenario: Notification tap — bid updated
- **WHEN** an advertiser taps a `bid_updated` push notification
- **THEN** the app navigates to the campaign bids list page for the `campaignId` in the payload

#### Scenario: Notification tap — bid withdrawn
- **WHEN** an advertiser taps a `bid_withdrawn` push notification
- **THEN** the app navigates to the campaign bids list page for the `campaignId` in the payload

#### Scenario: Missing or invalid campaignId in bid notification payload
- **WHEN** a bid notification payload does not contain a valid `campaignId`
- **THEN** the app navigates to the advertiser home page instead
- **AND** logs a warning for observability

---

### Requirement: Advertiser Foreground Bid Notification (Android)
The app SHALL display a heads-up notification banner when a bid notification arrives
while the advertiser has the app open on Android.

#### Scenario: Foreground bid_placed notification on Android
- **WHEN** a `bid_placed` FCM message arrives while the advertiser app is in the foreground on Android
- **THEN** a heads-up notification banner is shown via `flutter_local_notifications`
- **AND** the banner title and body match the FCM payload

#### Scenario: Foreground bid_updated or bid_withdrawn notification on Android
- **WHEN** a `bid_updated` or `bid_withdrawn` FCM message arrives in the foreground on Android
- **THEN** a heads-up notification banner is shown with the corresponding title and body

---

### Requirement: Advertiser Foreground Bid Notification (iOS)
The app SHALL present bid notifications as alerts when they arrive while the advertiser
has the app open on iOS.

#### Scenario: Foreground bid notification on iOS
- **WHEN** any bid-type FCM message arrives while the advertiser app is in the foreground on iOS
- **THEN** the notification is presented as an alert with sound via `UNUserNotificationCenter`

---

### Requirement: Promoter Bid Submission Confirmation Banner
The app SHALL show an in-app confirmation banner to the promoter immediately after
their bid is successfully submitted, updated, or withdrawn.

#### Scenario: Bid submitted successfully
- **WHEN** the promoter's bid submission API call returns success
- **THEN** a success toast is displayed: "Tu oferta fue enviada" (localised)
- **AND** the campaign detail screen reflects the new bid status

#### Scenario: Bid updated successfully
- **WHEN** the promoter's bid update API call returns success
- **THEN** a success toast is displayed: "Tu oferta fue actualizada" (localised)

#### Scenario: Bid withdrawn successfully
- **WHEN** the promoter's bid withdrawal API call returns success
- **THEN** a success toast is displayed: "Tu oferta fue retirada" (localised)

---

### Requirement: Localised Bid Notification Copy
Bid push notification content strings SHALL be available in all supported languages
(Spanish, English, Portuguese).

#### Scenario: Bid placed — Spanish
- **WHEN** the device locale is Spanish
- **THEN** the notification title is "Nueva oferta en tu campaña"
- **AND** the body includes the promoter name and proposed price

#### Scenario: Bid placed — English
- **WHEN** the device locale is English
- **THEN** the notification title is "New bid on your campaign"
- **AND** the body includes the promoter name and proposed price

#### Scenario: Bid placed — Portuguese
- **WHEN** the device locale is Portuguese
- **THEN** the notification title is "Nova oferta na sua campanha"
- **AND** the body includes the promoter name and proposed price

#### Scenario: Bid updated — Spanish
- **WHEN** the device locale is Spanish
- **THEN** the notification title is "Oferta actualizada"

#### Scenario: Bid withdrawn — Spanish
- **WHEN** the device locale is Spanish
- **THEN** the notification title is "Oferta retirada"

