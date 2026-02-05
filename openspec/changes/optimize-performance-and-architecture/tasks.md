# Implementation Tasks

## Phase 1: Quick Wins (Code Quality & Easy Optimizations)

- [x] 1.1 Extract magic numbers to constants file
  - Created `lib/shared/constants/time_thresholds.dart`
  - Moved hardcoded values from `live_campaign_models.dart` (2min, 5min stale/noSignal thresholds)
  - Moved polling interval from `advertiser_live_notifier.dart` (10s)
  - Added constants for retry logic, timeouts, signal strength thresholds
  - Validation: All hardcoded numbers replaced with constants

- [ ] 1.2 Remove deprecated fields from Campaign model
  - BLOCKED: Requires database schema migration - the CampaignsEntity table uses advertiserId, startDate, endDate fields
  - Need to create migration to rename startDate→startTime, endDate→endTime, and advertiserId→createdById
  - Validation: Code compiles, no references to deprecated fields

- [x] 1.3 Remove incomplete feature implementations
  - Social login is already properly disabled with `_kSocialLoginEnabled = false` flag
  - Payment methods page has TODO stubs but is a functional placeholder UI
  - No broken code to remove - these are proper feature-gated placeholders
  - Validation: Build succeeds, UI renders without issues

## Phase 2: Performance Optimizations (Database & State)

- [x] 2.1 Fix GPS N+1 query problem
  - Modified `lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart`
  - Replaced loop-based `getGpsPoints()` calls with batch query using `_getGpsPointsForRoutes()`
  - Updated `getRoutes()` and `getPendingSyncRoutes()` to use batch loading
  - Uses `routeId IN (ids)` pattern for single database query
  - Validation: Routes now load with 2 queries instead of N+1

- [x] 2.2 Implement request deduplication for live campaign polling
  - Updated `lib/features/advertiser/campaign_management/presentation/providers/advertiser_live_notifier.dart`
  - Added `_isRefreshing` flag to track in-flight requests
  - Added `_pendingRefresh` flag to queue single pending request
  - New requests during refresh are deduplicated to single pending request
  - Validation: Polling does not create overlapping requests

- [x] 2.3 Remove artificial permission request delays
  - Removed `Future.delayed()` calls from `lib/features/auth/presentation/providers/permission_provider.dart`
  - Sequential await already blocks until user responds to permission dialog
  - Validation: Permissions requested without artificial pauses

- [x] 2.4 Fix state mutation efficiency
  - Updated `markAlertAsRead()` in `advertiser_live_notifier.dart`
  - Replaced `.map().toList()` with index-based immutable update
  - Uses pattern: find index, create new list, assign by index
  - Validation: Single-item updates are now O(1) mentally and similar performance

- [x] 2.5 Add autoDispose to unused providers
  - Added `.autoDispose` to `campaignByIdProvider` (FutureProvider.family)
  - Added `.autoDispose` to `activeCampaignsProvider`
  - Kept infrastructure providers without autoDispose (database, config, theme)
  - Validation: Memory profiling should show reduced cache retention

## Phase 3: Error Handling & Architecture

- [x] 3.1 Create Result<T, E> type
  - Created `lib/core/models/result.dart`
  - `Result<T, E>` sealed class with `Success<T, E>` and `Failure<T, E>`
  - Includes `fold()`, `mapSuccess()`, `mapFailure()`, `flatMap()` methods
  - Includes `getOrElse()`, `getOrElseCompute()`, `isSuccess`, `isFailure` helpers
  - Validation: Type compiles and can be used in repositories

- [x] 3.2 Implement error type hierarchy
  - Created `lib/core/models/app_error.dart` with sealed class hierarchy:
    - `NetworkError` (timeout, no connection, transient flag)
    - `ParsingError` (invalid JSON, missing field, type mismatch)
    - `AuthError` (unauthorized, forbidden, invalid token, refresh failed)
    - `ServerError` (500+, transient flag)
    - `ValidationError` (422, field errors)
    - `NotFoundError` (404, resource info)
    - `UnknownError` (catch-all)
  - All error types include cause, stackTrace, and factory constructors
  - Validation: Error types cover all API failure scenarios

- [x] 3.3 Migrate campaign repository to Result pattern
  - Updated `lib/features/advertiser/campaign_management/domain/repositories/campaign_repository.dart` interface
  - Updated `lib/features/advertiser/campaign_management/data/repositories/campaign_repository_impl.dart` implementation
  - Updated `lib/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart` to handle Result
  - Updated `lib/shared/providers/providers.dart` kpiStatsProvider for Result
  - Added `_mapException()` and `_mapDioException()` for error mapping
  - Validation: All repository methods return Result<T, AppError>

- [x] 3.4 Fix unsafe JSON deserialization
  - Updated `lib/features/advertiser/campaign_management/data/datasources/remote/advertiser_live_remote_data_source.dart`
  - Added safe parsing helpers: `_extractListFromResponse`, `_parseListSafely`, `_asMapOrThrow`
  - Added type-safe field accessors: `_getString`, `_getStringOrNull`, `_getStringOrDefault`, `_getBoolOrDefault`, `_getDateTimeOrDefault`
  - Removed unsafe `as Map<String, dynamic>` and `as List` casts
  - Validation: No unsafe casts remain, type errors caught as ParsingError

- [x] 3.5 Add structured error logging
  - Created `lib/shared/services/error_logger.dart`
  - `logError(operation, error, stackTrace, context)` with structured output
  - `logWarning()` for non-error situations
  - `logRetry()`, `logRetrySuccess()`, `logRetryExhausted()` for retry tracking
  - Formatted output with timestamp, operation, error type, message, context
  - Validation: Error logs appear with full context

- [x] 3.6 Implement retry logic with exponential backoff
  - Created `lib/shared/services/retry_service.dart`
  - `retryAsync<T>(operation, operationName, maxRetries, baseDelay, maxDelay)`
  - Exponential backoff: 1s, 2s, 4s, 8s (configurable via TimeThresholds)
  - Transient error detection (timeout, 5xx, connection reset, socket errors)
  - Non-transient errors (401, 422, 404) fail immediately
  - Integration with ErrorLogger for retry tracking
  - Validation: Failed transient requests retry with exponential delays

- [x] 3.7 Fix token refresh interceptor race condition
  - Updated `lib/shared/services/token_refresh_interceptor.dart`
  - Replaced boolean flag with `Completer<String?>` async lock pattern
  - All concurrent 401 requests wait on single refresh operation
  - Once refresh completes, all waiting requests proceed with new token
  - Validation: Multiple concurrent 401 responses result in single refresh call

## Phase 4: Architecture Cleanup

- [ ] 4.1 Move auth providers to feature layer
  - Create `lib/features/auth/presentation/providers/auth_providers.dart`
  - Move providers from `lib/shared/providers/providers.dart`:
    - `authRepositoryProvider`
    - `authDataSourceProvider`
    - `authNotifierProvider`
  - Update all imports across codebase
  - Validation: Build succeeds, no circular dependencies

- [ ] 4.2 Separate monolithic providers file
  - Create feature-specific provider files:
    - `lib/features/advertiser/campaign_management/presentation/providers/providers.dart`
    - `lib/features/promotor/gps_tracking/presentation/providers/providers.dart`
    - `lib/features/location/presentation/providers/providers.dart`
  - Move relevant providers from `lib/shared/providers/providers.dart`
  - Validation: No feature cross-dependencies remain

- [ ] 4.3 Consolidate API response formats
  - Document final API contract for all endpoints
  - Remove legacy fallback logic from `advertiser_live_remote_data_source.dart`
  - Keep single, canonical response parser per endpoint
  - Validation: Response handling is straightforward, no multiple format support

- [ ] 4.4 Remove feature-to-feature dependencies
  - Audit imports in each feature for cross-feature dependencies
  - Move shared logic to `core/` or `shared/`
  - Examples: Campaign models, rating logic, location utilities
  - Validation: `rg 'features/[a-z]+/data' lib/features/` returns no results across features

## Validation & Testing

- [ ] 5.1 Performance benchmarking
  - Measure database query time before/after optimization
  - Measure API polling overlap before/after deduplication
  - Measure state mutation time before/after
  - Document improvements in PR description

- [ ] 5.2 Integration testing
  - Test live campaign polling with network conditions
  - Test GPS data loading with 100+ routes
  - Test concurrent token refresh scenarios
  - Test error recovery with retry logic

- [ ] 5.3 Memory profiling
  - Profile memory before/after `.autoDispose` addition
  - Verify no memory leaks from cached providers
  - Test memory on repeated navigation

- [ ] 5.4 Code review checklist
  - No unsafe casts remain (as, !)
  - All repositories use Result type
  - All errors logged with context
  - Feature dependencies removed
  - Magic numbers extracted
  - Tests pass

## Rollback & Contingency

- [ ] 6.1 Rollback plan
  - Maintain branch point before starting Phase 3+
  - Can rollback architecture changes independently
  - Each phase is independently testable
  - Data migrations (if any) are reversible

---

## Notes

- **Sequential Phases**: Complete Phase 1 first before Phase 2. Phase 3 and 4 can happen in parallel after Phase 2.
- **Build Testing**: After each phase, run `flutter pub get && flutter analyze && flutter test` to verify no regressions.
- **API Contract**: Coordinate with backend team before consolidating API response formats (task 4.3).
- **Backwards Compatibility**: All changes are backwards compatible from API perspective; only internal architecture changes.

## Implementation Summary (as of current session)

### Completed (12/19 tasks):
- Phase 1: 2/3 completed (1.2 blocked by database migration)
- Phase 2: 5/5 completed
- Phase 3: 5/7 completed (3.3, 3.4 pending - repository migration)
- Phase 4: 0/4 pending (architecture refactoring)

### Files Created:
- `lib/shared/constants/time_thresholds.dart` - Time-related constants
- `lib/core/models/result.dart` - Result<T, E> type for error handling
- `lib/core/models/app_error.dart` - Error type hierarchy
- `lib/shared/services/error_logger.dart` - Structured error logging
- `lib/shared/services/retry_service.dart` - Retry with exponential backoff

### Files Modified:
- `lib/features/advertiser/campaign_management/domain/models/live_campaign_models.dart` - Use TimeThresholds
- `lib/features/advertiser/campaign_management/presentation/providers/advertiser_live_notifier.dart` - Request deduplication, index-based updates
- `lib/features/auth/presentation/providers/permission_provider.dart` - Remove artificial delays
- `lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart` - Batch GPS queries
- `lib/shared/providers/providers.dart` - Add autoDispose to providers
- `lib/shared/services/token_refresh_interceptor.dart` - Fix race condition with Completer
