## Context
The backend defines a bidding lifecycle and a payment gate before campaign execution, but the mobile app has no implementation for bidding, bid review, or payment-gated start.

## Goals / Non-Goals
- Goals: implement end-to-end mobile bidding flow for promoters and advertisers; enforce payment gate before start; surface status-aware UI.
- Non-Goals: implement backend payment processing, admin tooling, or push notifications.

## Decisions
- Decision: create a new `campaign-bidding` capability rather than extending `campaign-creation`.
- Decision: keep backend as source of truth for bid/payment status; mobile uses polling on detail screens.
- Decision: reuse existing Result-based repository pattern and Riverpod providers.

## Alternatives Considered
- Reuse `campaign-management` capability for bidding. Rejected because bidding spans both promoter and advertiser roles and adds new data models.

## Risks / Trade-offs
- Polling may increase network usage. Mitigate with status-based intervals and stop polling on terminal states.
- Payment status visibility depends on backend response shape. Mitigate by allowing missing payment data to fall back to manual refresh.

## Migration Plan
- Add new data models and APIs without breaking existing campaign list screens.
- Update execution start gating and status labels after bidding screens are in place.

## Open Questions
- Should accepted bids and payment status be embedded in `GET /campaigns/{id}` or fetched via `GET /campaigns/{id}/bids` only?
- Should checkout be opened in-app (WebView) or external browser?
