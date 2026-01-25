## Context

The advertiser live view complements the existing promoter live tracking feature. While promoters track their own execution, advertisers need visibility into campaigns they've paid for. This creates a monitoring dashboard where advertisers can verify campaign delivery in real-time.

### Constraints

- Must work with existing campaign and GPS data models
- Backend must expose promoter location data to advertisers (only for their campaigns)
- Privacy: advertisers should only see location during active campaign execution
- Mapbox free tier: shared quota with promoter tracking
- Multiple campaigns may execute simultaneously

### Current State

- Promoter-side: GPS tracking is implemented and syncs to backend
- Advertiser-side: `AdvertiserLivePage` exists as a placeholder with mock data
- Backend: `/campaigns/{id}/gps-tracks` endpoint exists for GPS data
- Campaign model: includes `status`, `acceptedBy` (promoter info)

## Goals / Non-Goals

### Goals
- Display all advertiser's active campaigns on a map
- Show promoter locations for active campaigns (polling-based, ~10s interval)
- Allow campaign selection when multiple are active
- Display execution progress (distance, time, status)
- Show campaign event alerts (start, pause, complete, out-of-zone)
- Support switching between map and list views

### Non-Goals (Future Work)
- Real-time WebSocket updates (v1 uses polling)
- Historical playback of completed routes
- Push notifications for campaign events
- Geofencing alerts when promoter leaves coverage zone
- Chat with promoter

## Decisions

### 1. Data Refresh Strategy

**Decision**: Poll for live location data every 10 seconds

```dart
Timer.periodic(Duration(seconds: 10), (_) {
  ref.refresh(activeCampaignsProvider);
});
```

**Rationale**:
- Simple to implement without WebSocket infrastructure
- 10s interval balances freshness vs API load
- Promoter GPS syncs every 60s, so 10s polling is sufficient
- Can upgrade to WebSocket later without UI changes

### 2. Multi-Campaign Handling

**Decision**: Show all active campaigns on map, with campaign selector

**UI Flow**:
1. Map shows all active campaign routes and promoter markers
2. Bottom sheet lists campaigns with filters (Active, Pending, No Signal)
3. Tapping campaign in list zooms map to that campaign/promoter
4. "Follow" mode tracks selected promoter in real-time

**Rationale**:
- Advertisers may have multiple campaigns running
- Single map view avoids context switching
- Color-coded markers distinguish campaigns

### 3. Promoter Location Model

**Decision**: Create `LivePromoterLocation` model for real-time data

```dart
class LivePromoterLocation {
  final String campaignId;
  final String promoterId;
  final String promoterName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdate;
  final double distanceTraveled; // km
  final Duration elapsedTime;
  final CampaignExecutionStatus status; // active, paused
  final int signalStrength; // 0-4
}
```

**Rationale**:
- Distinct from GPS tracking model (this is read-only view)
- Includes computed progress metrics
- Signal strength indicates data freshness

### 4. API Endpoint Design

**Recommended endpoint**: `GET /advertiser/live-campaigns`

**Response**:
```json
{
  "campaigns": [
    {
      "id": "campaign-uuid",
      "title": "Campaign Name",
      "status": "executing",
      "promoter": {
        "id": "promoter-uuid",
        "name": "Mati C.",
        "location": {
          "lat": -34.9011,
          "lng": -56.1645,
          "updated_at": "2026-01-24T14:30:00Z"
        },
        "execution": {
          "status": "active",
          "distance_km": 5.2,
          "elapsed_minutes": 45,
          "started_at": "2026-01-24T13:45:00Z"
        }
      },
      "route_coordinates": [...],
      "coverage_zone": {...}
    }
  ]
}
```

**Rationale**:
- Single endpoint returns all live data needed
- Reduces API calls vs fetching each campaign separately
- Backend can optimize query for live campaigns only

### 5. Map Integration

**Decision**: Use Mapbox with multiple annotation layers

```dart
// Layers:
// 1. Route polylines (one per campaign, color-coded)
// 2. Promoter markers (current location)
// 3. Coverage zone polygons (semi-transparent)
```

**Rationale**:
- Consistent with promoter-side map implementation
- Color coding distinguishes multiple campaigns
- Coverage zones show expected advertising area

### 6. Alert System

**Decision**: In-app alert feed with badge indicator

**Alert types**:
- Campaign started (info)
- Campaign paused (warning)
- Campaign completed (success)
- No signal from promoter >5 min (warning)
- Promoter outside coverage zone (warning)

**Rationale**:
- Immediate visibility without leaving the page
- Badge count for unread alerts
- Future: can add push notifications

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Presentation Layer                            │
│  ┌─────────────────────────┐    ┌─────────────────────────────┐ │
│  │   AdvertiserLivePage    │    │   CampaignListSheet         │ │
│  │   (Mapbox + Controls)   │    │   (Bottom sheet list)       │ │
│  └──────────┬──────────────┘    └──────────────┬──────────────┘ │
│             │                                   │                │
│             ▼                                   ▼                │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │         AdvertiserLiveNotifier (Riverpod)                    ││
│  │  - Manages selected campaign                                  ││
│  │  - Handles refresh timer                                      ││
│  │  - Tracks alerts                                              ││
│  └──────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Domain Layer                                  │
│  ┌─────────────────────────┐    ┌─────────────────────────────┐ │
│  │ GetLiveCampaignsUseCase │    │ LivePromoterLocation        │ │
│  │ GetCampaignAlertsUseCase│    │ CampaignAlert               │ │
│  └─────────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Data Layer                                   │
│  ┌─────────────────────────┐    ┌─────────────────────────────┐ │
│  │ AdvertiserLiveRepository │    │ LiveCampaignRemoteDataSource│ │
│  │ (Abstract + Impl)       │    │ (API calls)                 │ │
│  └─────────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Polling creates API load | 10s interval is reasonable; backend can cache |
| Stale location data | Show "last updated" timestamp; gray out if >2min old |
| No active campaigns | Show empty state with helpful message |
| Backend not ready | Can develop with mock data; feature flag |
| Map performance with many campaigns | Limit to 10 active campaigns visible; use clustering |
| Privacy concerns | Backend must validate advertiser owns campaign |

## Migration Plan

No migration needed - this is new functionality. Replaces placeholder UI.

## Open Questions

1. **What polling interval is acceptable?** - Proposed 10 seconds
2. **Should we support WebSocket for real-time?** - Not for v1; polling is simpler
3. **Maximum concurrent campaigns to display?** - Suggest 10 with pagination
4. **Backend API availability?** - Need to coordinate endpoint development
