# Change: Add Push Notifications for Promoter Bid Placement

## Why
When a promoter submits a bid on a campaign the advertiser currently has no real-time
signal — they must poll the app manually. A push notification closes this gap, accelerates
bid review, and increases the probability that campaigns move from `created` to `accepted`
quickly.

## What Changes
- Backend sends an FCM push notification to the advertiser's device when a promoter
  submits, updates, or withdraws a bid on one of their campaigns.
- Mobile (advertiser side) handles the notification and deep-links to the campaign bids
  list page.
- Mobile (promoter side) shows a foreground in-app confirmation banner when their own
  bid submission succeeds (reuses `flutter_local_notifications` already added by
  `add-campaign-available-push-notifications`).
- All notification copy is localised (ES / EN / PT).

**Dependency:** This change assumes `add-campaign-available-push-notifications` is
implemented first (FCM setup, device token registration endpoint, and
`flutter_local_notifications` are already in place).

## Impact

- Affected specs:
  - `push-notifications-bid-mobile` (new — Flutter/advertiser side)
  - `push-notifications-bid-backend` (new — Laravel backend side)
- Affected code (mobile):
  - `lib/shared/services/push_notification_service.dart` — extend handler to route
    `bid_placed`, `bid_updated`, `bid_withdrawn` notification types
  - `lib/app/` — register new notification type routes
  - `lib/gen/l10n/` — add bid notification copy strings
- Affected code (backend — Laravel):
  - `app/Services/BidNotificationService.php` — FCM dispatch on bid events
  - `app/Observers/BidObserver.php` — trigger on bid created / updated / withdrawn
  - `app/Http/Controllers/DeviceTokenController.php` — already exists (no change needed)
