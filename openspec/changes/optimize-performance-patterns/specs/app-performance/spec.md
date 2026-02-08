# Specification Delta: App Performance

## ADDED Requirements
### Requirement: Database Query Optimization
The database layer SHALL use indexes on frequently queried columns to improve query performance.

#### Scenario: GPS point queries use indexes
- **WHEN** querying GPS points by `routeId`, `campaignId`, or `syncedAt`
- **THEN** database uses indexes to execute queries within acceptable latency (<100ms for 10k points)

#### Scenario: Campaign list queries optimized
- **WHEN** querying campaigns by `status` or `createdAt`
- **THEN** database indexes are used for efficient filtering

### Requirement: Campaign List Pagination
Large campaign lists SHALL be paginated to prevent memory exhaustion and improve UI responsiveness.

#### Scenario: Pagination enabled for campaign browse
- **WHEN** user views campaign list in advertiser or promoter view
- **THEN** campaigns are loaded in pages of configurable size (default 20)

#### Scenario: Load more functionality
- **WHEN** user scrolls to bottom of campaign list
- **THEN** next page is automatically fetched and appended (infinite scroll)

#### Scenario: Offline pagination works
- **WHEN** cached campaigns are paginated during offline use
- **THEN** pagination uses local database pagination, not in-memory filtering

### Requirement: Provider Watch Efficiency
State providers SHALL minimize unnecessary widget rebuilds by using selective watching patterns.

#### Scenario: Focused KPI updates
- **WHEN** campaign data changes
- **THEN** only KPI widget rebuilds; unrelated widgets are not rebuilt

#### Scenario: No double-loading
- **WHEN** a page initializes
- **THEN** provider is fetched exactly once; no redundant refresh in `initState` or `addPostFrameCallback`

### Requirement: GPS Tracking Configuration
GPS tracking parameters SHALL be configurable to support different use cases and optimize battery consumption.

#### Scenario: Batch size configurable
- **WHEN** GPS tracking initializes
- **THEN** batch size for syncing points is read from `GpsTrackingConfig` (default 20)

#### Scenario: Sync interval configurable
- **WHEN** GPS tracking is active
- **THEN** sync interval is read from `GpsTrackingConfig` (default 60 seconds)

#### Scenario: Distance filter configurable
- **WHEN** location service starts
- **THEN** distance filter is read from `GpsTrackingConfig` (default 10 meters)

### Requirement: Widget Allocation Optimization
Widgets SHALL use `const` constructors where applicable to reduce allocation overhead.

#### Scenario: Const constructors used for static widgets
- **WHEN** a widget has no mutable state or external dependencies
- **THEN** it is declared with `const` keyword to enable compiler deduplication

## MODIFIED Requirements
### Requirement: First Campaign Sync Logic
The first campaign detection mechanism SHALL not cause double-loading of campaign data.

#### Scenario: Single load on first campaign change
- **WHEN** campaigns are fetched from remote
- **THEN** FirstCampaignNotifier updates based on provider change, without triggering additional refresh
