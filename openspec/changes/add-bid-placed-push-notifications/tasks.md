## Prerequisites
- [ ] 0.1 Confirm `add-campaign-available-push-notifications` is implemented (FCM bootstrap,
      device token endpoint, `flutter_local_notifications`, `PushNotificationService` all present)

## 1. Mobile — Notification Routing
- [ ] 1.1 Add `bid_placed`, `bid_updated`, `bid_withdrawn` cases to `_handleNotificationNavigation()`
      in `PushNotificationService`
- [ ] 1.2 Implement navigation to campaign bids list: extract `campaignId` from `data` payload
      and push the bids list route via GoRouter
- [ ] 1.3 Guard against missing `campaignId` — fall back to advertiser home, log warning
- [ ] 1.4 Wire up foreground Android handling: pass bid notification types through
      `flutter_local_notifications` display path
- [ ] 1.5 Verify iOS foreground presentation options already cover bid notification types
      (no extra config expected)

## 2. Mobile — Promoter Confirmation Banners
- [ ] 2.1 Show success toast "Tu oferta fue enviada" after successful bid submission
      (call `notificationService.showToast(...)` in bid submission notifier)
- [ ] 2.2 Show success toast "Tu oferta fue actualizada" after successful bid update
- [ ] 2.3 Show success toast "Tu oferta fue retirada" after successful bid withdrawal

## 3. Mobile — Localisation
- [ ] 3.1 Add ARB keys to `lib/l10n/app_es.arb`, `app_en.arb`, `app_pt.arb`:
      - `bidPlacedNotificationTitle` / `bidPlacedNotificationBody`
      - `bidUpdatedNotificationTitle` / `bidUpdatedNotificationBody`
      - `bidWithdrawnNotificationTitle` / `bidWithdrawnNotificationBody`
      - `bidSubmittedToast`, `bidUpdatedToast`, `bidWithdrawnToast`
- [ ] 3.2 Run `flutter gen-l10n` to regenerate `lib/gen/l10n/` files
- [ ] 3.3 Replace hardcoded Spanish strings in `PushNotificationService` and bid notifier
      with localised keys

## 4. Backend — BidNotificationService
- [ ] 4.1 Create `app/Services/BidNotificationService.php` with three public methods:
      - `notifyBidPlaced(Bid $bid)`
      - `notifyBidUpdated(Bid $bid)`
      - `notifyBidWithdrawn(Bid $bid)`
- [ ] 4.2 Each method resolves the campaign's advertiser `fcm_token`; skips if null
- [ ] 4.3 Build FCM payload per the agreed contract (type, campaignId, bidId,
      notification title/body, android channel_id)
- [ ] 4.4 Send via `kreait/firebase-php` single-device message
- [ ] 4.5 Handle FCM error response: nullify stale token on `UNREGISTERED` / `INVALID_ARGUMENT`
- [ ] 4.6 Wrap dispatch in try/catch — log error, do not re-throw (non-blocking)

## 5. Backend — BidObserver
- [ ] 5.1 Create `app/Observers/BidObserver.php`
      - `created()` → `BidNotificationService::notifyBidPlaced()`
      - `updated()` → check dirty fields:
        - `proposed_price` changed + status `pending` → `notifyBidUpdated()`
        - `status` changed to `withdrawn` → `notifyBidWithdrawn()`
- [ ] 5.2 Register observer in `app/Providers/AppServiceProvider.php`:
      `Bid::observe(BidObserver::class)`

## 6. Testing & QA
- [ ] 6.1 Send a test `bid_placed` FCM message via Firebase console to an advertiser's
      Android device; verify notification appears and tapping opens the bids list
- [ ] 6.2 Repeat on iOS
- [ ] 6.3 Verify foreground notification banner on Android while advertiser app is open
- [ ] 6.4 Verify promoter toast banners for submit, update, and withdraw
- [ ] 6.5 Verify no notification is sent when only bid message text changes (price unchanged)
- [ ] 6.6 Verify stale token cleanup (revoke token from Firebase console, trigger bid event)
- [ ] 6.7 Verify graceful skip when advertiser has no `fcm_token`
