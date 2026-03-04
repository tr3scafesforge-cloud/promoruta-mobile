# Design: Push Notifications for Promoter Bid Placement

## Context
The campaign bidding flow allows multiple promoters to bid on a single campaign.
The advertiser must review bids and accept one. Currently, the advertiser discovers
new bids only by opening the app and checking the bids list.

This change adds FCM push notifications so the advertiser is alerted in real time
for three bid events: **bid placed**, **bid updated**, and **bid withdrawn**.
The mobile infrastructure (FCM, `flutter_local_notifications`, device token endpoint)
is assumed to already be in place from `add-campaign-available-push-notifications`.

## Goals / Non-Goals

**Goals**
- Notify the advertiser on bid placed, bid updated, and bid withdrawn.
- Deep-link the advertiser to the campaign bids list on notification tap.
- Show a foreground confirmation toast to the promoter after a successful bid submission
  (local, no FCM needed).
- Support Android and iOS.

**Non-Goals**
- Notifying other promoters about competing bids (privacy concern).
- Bid acceptance / rejection notifications to the promoter (separate future change).
- Batching multiple bids into a single digest notification.
- Notification preferences / mute controls.

## Decisions

### 1. Target: advertiser's device only
The FCM message is sent to the advertiser who owns the campaign (`campaign.advertiser_id`).
Only one device token is targeted per notification (the advertiser's stored `fcm_token`).

### 2. Three triggering events
| Event | Bid status transition | Notification |
|---|---|---|
| Bid placed | `null → pending` | "New bid on your campaign" |
| Bid updated | `pending → pending` (price changed) | "A promoter updated their bid" |
| Bid withdrawn | `pending → withdrawn` | "A promoter withdrew their bid" |

### 3. Reuse existing `PushNotificationService` on mobile
No new service class is needed. The existing handler already dispatches based on
`data.type`. Two new type values are added: `bid_placed`, `bid_updated`, `bid_withdrawn`.

### 4. Promoter foreground confirmation is local-only
After a successful bid API call, the promoter app shows a toast via the existing
`OverlayNotificationService`. No FCM round-trip is needed for this.

### 5. BidObserver pattern on Laravel
A `BidObserver` listens to Eloquent model events (`created`, `updated`) and calls
`BidNotificationService`. This keeps notification logic out of controllers.

## Notification Payload Contract

### Bid placed
```json
{
  "notification": {
    "title": "Nueva oferta en tu campaña",
    "body": "{{promoterName}} ha enviado una oferta de ${{proposedPrice}}"
  },
  "data": {
    "type": "bid_placed",
    "campaignId": "{{campaign.id}}",
    "bidId": "{{bid.id}}"
  }
}
```

### Bid updated
```json
{
  "notification": {
    "title": "Oferta actualizada",
    "body": "{{promoterName}} actualizó su oferta a ${{proposedPrice}}"
  },
  "data": {
    "type": "bid_updated",
    "campaignId": "{{campaign.id}}",
    "bidId": "{{bid.id}}"
  }
}
```

### Bid withdrawn
```json
{
  "notification": {
    "title": "Oferta retirada",
    "body": "{{promoterName}} retiró su oferta de tu campaña"
  },
  "data": {
    "type": "bid_withdrawn",
    "campaignId": "{{campaign.id}}",
    "bidId": "{{bid.id}}"
  }
}
```

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Advertiser has no registered FCM token | Skip FCM call gracefully; bid still succeeds |
| High bid volume causes notification spam | Acceptable for MVP; throttling deferred |
| FCM API failure | Log error; bid operation is not rolled back |
| Advertiser denies notification permission | App works normally; they miss real-time alerts |

## Open Questions
- Should bid-updated notifications only fire if the proposed price changes, or also if the message changes? (Assumed: price change only, to reduce noise.)
