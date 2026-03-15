# push-notifications-bid-backend Specification

## Purpose
TBD - created by archiving change add-bid-placed-push-notifications. Update Purpose after archive.
## Requirements
### Requirement: Bid Placed Notification Dispatch
The backend SHALL send an FCM push notification to the campaign's advertiser when a
promoter successfully submits a new bid.

#### Scenario: Advertiser notified on bid placed
- **WHEN** a promoter submits a bid and `POST /campaigns/:id/bids` succeeds
- **THEN** the backend retrieves the advertiser's `fcm_token` from the `users` table
- **AND** sends a single-device FCM message with `data.type = "bid_placed"`
- **AND** the FCM payload `notification.title` is "Nueva oferta en tu campaña"
- **AND** the FCM payload `notification.body` includes the promoter's name and proposed price
- **AND** the FCM payload `data.campaignId` and `data.bidId` are included

#### Scenario: Advertiser has no FCM token
- **WHEN** the advertiser does not have a stored `fcm_token`
- **THEN** the backend skips the FCM call silently
- **AND** the bid is still created successfully (notification is non-blocking)

#### Scenario: FCM API call fails on bid placed
- **WHEN** the FCM HTTP v1 API returns an error during bid placed dispatch
- **THEN** the backend logs the error for observability
- **AND** the bid creation is not rolled back

---

### Requirement: Bid Updated Notification Dispatch
The backend SHALL send an FCM push notification to the campaign's advertiser when a
promoter updates their existing bid price.

#### Scenario: Advertiser notified on bid updated
- **WHEN** a promoter sends `PUT /campaigns/:id/bids/:bidId` and the proposed price changes
- **THEN** the backend sends an FCM message with `data.type = "bid_updated"`
- **AND** the FCM payload `notification.title` is "Oferta actualizada"
- **AND** the FCM payload `notification.body` includes the promoter's name and the new proposed price
- **AND** the FCM payload `data.campaignId` and `data.bidId` are included

#### Scenario: No notification when only message text changes
- **WHEN** a promoter updates their bid but only the `message` field changes (price unchanged)
- **THEN** no FCM notification is sent

---

### Requirement: Bid Withdrawn Notification Dispatch
The backend SHALL send an FCM push notification to the campaign's advertiser when a
promoter withdraws their bid.

#### Scenario: Advertiser notified on bid withdrawn
- **WHEN** a promoter sends `POST /campaigns/:id/bids/:bidId/withdraw` and the bid status
  becomes `withdrawn`
- **THEN** the backend sends an FCM message with `data.type = "bid_withdrawn"`
- **AND** the FCM payload `notification.title` is "Oferta retirada"
- **AND** the FCM payload `notification.body` includes the promoter's name
- **AND** the FCM payload `data.campaignId` and `data.bidId` are included

---

### Requirement: Bid FCM Payload Contract
The backend SHALL produce FCM messages for bid events conforming to the agreed payload
schema so the mobile app can parse and navigate correctly.

#### Scenario: bid_placed payload structure
- **WHEN** the backend dispatches a `bid_placed` FCM message
- **THEN** the payload contains `notification.title`, `notification.body`, `data.type`,
  `data.campaignId`, and `data.bidId`
- **AND** `data.type` equals `"bid_placed"`

#### Scenario: bid_updated payload structure
- **WHEN** the backend dispatches a `bid_updated` FCM message
- **THEN** the payload structure mirrors `bid_placed` with `data.type = "bid_updated"`

#### Scenario: bid_withdrawn payload structure
- **WHEN** the backend dispatches a `bid_withdrawn` FCM message
- **THEN** the payload structure mirrors `bid_placed` with `data.type = "bid_withdrawn"`

#### Scenario: Android channel targeting for bid notifications
- **WHEN** any bid FCM message is destined for an Android device
- **THEN** `android.notification.channel_id` is set to `"campaign_alerts"`

---

### Requirement: Bid Notification Observer
The backend SHALL use a Laravel Eloquent observer on the `Bid` model to trigger
notification dispatch so that bid notification logic is decoupled from controllers.

#### Scenario: Observer fires on bid created
- **WHEN** a `Bid` model is persisted for the first time (Eloquent `created` event)
- **THEN** `BidObserver::created()` calls `BidNotificationService::notifyBidPlaced()`

#### Scenario: Observer fires on bid status change to withdrawn
- **WHEN** a `Bid` model is updated and `status` transitions to `withdrawn`
- **THEN** `BidObserver::updated()` calls `BidNotificationService::notifyBidWithdrawn()`

#### Scenario: Observer fires on bid price update
- **WHEN** a `Bid` model is updated and `proposed_price` has changed
- **AND** the new status is still `pending`
- **THEN** `BidObserver::updated()` calls `BidNotificationService::notifyBidUpdated()`

---

### Requirement: Stale Advertiser Token Cleanup
The backend SHALL remove an advertiser's FCM token if the FCM API reports it as
invalid during a bid notification send.

#### Scenario: Token invalidated during bid notification
- **WHEN** the FCM API returns `UNREGISTERED` or `INVALID_ARGUMENT` for the advertiser's token
- **THEN** the backend sets `fcm_token = null` on the advertiser's user record
- **AND** the stale token is not used in future sends

