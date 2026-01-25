# Change: Add Advertiser Live Campaign View

## Why

Advertisers need real-time visibility into their active campaigns to monitor promoter progress, verify execution, and ensure their advertising investment is being delivered as expected. Currently, the advertiser "Live" tab shows a placeholder UI with hardcoded mock data. This feature will enable advertisers to:

1. See all their currently executing campaigns on a map
2. Track individual promoters in real-time
3. Monitor campaign progress (distance, time, route)
4. Receive alerts about campaign execution events

## What Changes

### New Capabilities
- **Multi-Campaign Live Dashboard**: Display all active campaigns belonging to the advertiser on a single map view
- **Campaign Selection**: Allow switching focus between multiple concurrent active campaigns
- **Promoter Live Location**: Show real-time GPS position of promoters executing campaigns
- **Progress Metrics**: Display distance traveled, elapsed time, and route completion percentage
- **Activity Alerts**: Show notifications for campaign events (started, paused, completed, out-of-zone)

### Affected Code
- `lib/features/advertiser/campaign_management/` - New live tracking data layer
- `lib/presentation/advertiser/pages/advertiser_live_page.dart` - Replace placeholder with functional UI
- `lib/core/models/` - New models for live promoter location
- `lib/shared/providers/` - New providers for live campaign state

### API Dependencies
This feature depends on backend endpoints for:
- Fetching active campaigns with execution status
- Polling/streaming promoter live location data
- Campaign execution event notifications

**Note**: Real-time updates could use polling (simpler) or WebSockets (more responsive). Polling is recommended for v1.

## Impact

- **Affected specs**: None (new capability)
- **New specs**: `advertiser-live-view`
- **Backend coordination**: Requires API endpoints for promoter location data
- **Mapbox usage**: Additional map loads count toward quota (50k/month free tier)
