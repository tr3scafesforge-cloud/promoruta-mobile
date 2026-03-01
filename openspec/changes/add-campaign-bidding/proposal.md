# Change: Add Campaign Bidding Flow

## Why
The mobile app lacks the bidding flow required by the backend contract, so promoters and advertisers cannot place, review, or accept bids and cannot progress campaigns into execution.

## What Changes
- Add a new `campaign-bidding` capability covering bid submission, review, acceptance, and payment-gated start.
- **BREAKING** Update campaign execution preconditions to require payment confirmation before starting.
- Add UI states and status labels for `created`, `accepted`, `in_progress`, `completed`, `cancelled`, and `expired`.
- Add polling behavior on campaign detail during bidding/acceptance.

## Impact
- Affected specs: `campaign-bidding` (new), `promoter-live-tracking` (modified)
- Affected code: promoter browsing & execution screens, advertiser campaign detail, campaign models/status mapping, remote data sources, providers, localization
