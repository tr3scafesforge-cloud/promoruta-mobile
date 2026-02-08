# Implementation Tasks: Optimize Performance Patterns

## 1. Database Optimization

- [ ] 1.1 Add indexes to `gps_points` table on `routeId`, `campaignId`, `syncedAt`, `synced`
- [ ] 1.2 Add indexes to `campaigns` table on `status`, `createdAt`, `syncedAt`
- [ ] 1.3 Run migration to apply indexes
- [ ] 1.4 Test query performance with EXPLAIN QUERY PLAN on common queries

## 2. Campaign List Pagination

- [ ] 2.1 Create `CampaignQueryParams` model with `page` and `limit` fields (if not exists)
- [ ] 2.2 Update `CampaignLocalDataSource.getCampaigns()` to support pagination
- [ ] 2.3 Update `CampaignRemoteDataSource.getCampaigns()` to request paginated results
- [ ] 2.4 Create pagination controller in `CampaignsNotifier` for load-more functionality
- [ ] 2.5 Update `advertiser_home_page.dart` to use pagination provider
- [ ] 2.6 Add "Load More" or infinite scroll UI pattern

## 3. Provider Watching Optimization

- [ ] 3.1 Refactor `advertiser_home_page.dart` to use selective watching with `select()`
- [ ] 3.2 Split multi-provider watches into focused sub-widgets (KPI card as separate ConsumerWidget)
- [ ] 3.3 Remove double-loading: remove `addPostFrameCallback` refresh if provider already triggers
- [ ] 3.4 Convert all provider-dependent widgets to ConsumerWidget pattern
- [ ] 3.5 Add `keepAlive: true` to campaign list provider to avoid re-fetching

## 4. GPS Tracking Parametrization

- [ ] 4.1 Create `GpsTrackingConfig` model with `batchSize`, `syncIntervalSeconds`, `distanceFilterMeters`
- [ ] 4.2 Create GPS config provider in `infrastructure_providers.dart`
- [ ] 4.3 Update `LocationService` to accept config via constructor injection
- [ ] 4.4 Update `campaign_execution_notifier.dart` to use parametrized constants
- [ ] 4.5 Add optional environment configuration for GPS settings

## 5. Widget Optimization

- [ ] 5.1 Add `const` constructors to KPI card widgets in advertiser_home_page.dart
- [ ] 5.2 Add `const` constructors to campaign list item widgets
- [ ] 5.3 Add `const` constructors to location tracking UI widgets
- [ ] 5.4 Audit all presentation widgets for unnecessary rebuilds (use DevTools profiler)

## 6. State Synchronization Cleanup

- [ ] 6.1 Remove redundant `syncWithCampaigns()` calls in FirstCampaignNotifier
- [ ] 6.2 Consolidate refresh logic in CampaignsNotifier (one source of truth)
- [ ] 6.3 Use provider `.select()` to watch only relevant state slices
- [ ] 6.4 Document when/why each provider refreshes

## 7. Testing and Validation

- [ ] 7.1 Add performance regression tests for campaign list loading
- [ ] 7.2 Verify GPS sync works with different `batchSize` values
- [ ] 7.3 Profile app with DevTools during heavy campaign list operations
- [ ] 7.4 Verify pagination doesn't break offline functionality
- [ ] 7.5 Run all tests and ensure no performance degradation
