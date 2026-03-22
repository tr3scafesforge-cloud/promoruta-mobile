# Change: Use live active campaign data on promoter home

## Why
The promoter home page still renders a hardcoded active campaign card, which can show incorrect campaign status, progress, and payout information. The home dashboard should reflect the promoter's real active campaign from the existing campaigns endpoint.

## What Changes
- Replace the hardcoded active campaign card on the promoter home page with data loaded from the existing promoter active campaigns query.
- Reuse the current endpoint filtering for the logged-in promoter's `in_progress` campaigns instead of adding a new backend contract.
- Show an empty state when the promoter has no active campaign instead of placeholder campaign content.

## Impact
- Affected specs: `promoter-live-tracking`
- Affected code: `lib/features/promotor/presentation/pages/promoter_home_page.dart`, existing active campaign providers reused from campaign management
