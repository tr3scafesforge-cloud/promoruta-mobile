# Change: Optimize Performance and Architecture

## Why

The codebase has several functional and performance issues that impact user experience and maintenance:

1. **Performance Bottlenecks**: Database N+1 queries, undeduped API polling, and inefficient list operations cause UI lag and memory issues
2. **Architecture Violations**: Features depend on shared layer incorrectly, creating circular dependencies and violating the feature-first clean architecture
3. **Resilience Gaps**: Inconsistent error handling, unsafe JSON parsing, and race conditions in token refresh reduce reliability
4. **Code Maintenance**: Hardcoded magic numbers, deprecated fields, and unused features create technical debt

These issues compound as the codebase grows, making future development slower and riskier.

## What Changes

### 1. **Data Access Optimization**
- Fix N+1 query problem in GPS tracking (batch load instead of loop)
- Implement proper database indices for frequently queried fields
- Add query result caching at repository layer

### 2. **State Management Improvements**
- Implement request deduplication for polling operations
- Add `.autoDispose` to unused providers to prevent memory leaks
- Replace `.map().toList()` patterns with immutable index-based updates
- Remove artificial delays in permission handling

### 3. **Error Handling Standardization**
- Implement `Result<T, E>` type for consistent error handling across repositories
- Replace force unwrapping (`!` operator) and unsafe casts with proper validation
- Add structured logging for silent failures
- Implement retry logic with exponential backoff

### 4. **Architecture Cleanup**
- Move auth providers from shared layer to feature layer
- Separate massive `providers.dart` (600+ lines) into feature-specific modules
- Remove feature cross-dependencies
- Implement dependency inversion where concrete types are used

### 5. **Code Quality**
- Remove deprecated fields from data models
- Extract magic numbers to constants
- Remove incomplete feature implementations (social login, payment stubs)
- Consolidate multiple API response format handling

## Impact

- **Affected specs**: advertiser-live-view, promoter-live-tracking, user-registration
- **Affected code**:
  - `lib/features/advertiser/campaign_management/` (live tracking)
  - `lib/features/promotor/gps_tracking/` (GPS data)
  - `lib/features/auth/` (auth state)
  - `lib/shared/providers/` (all providers)
  - `lib/shared/services/` (token refresh, sync)
  - `lib/core/models/` (data models)

## Breaking Changes

- **Auth providers location**: Moving from `shared` to `features/auth` requires import updates across codebase
- **Error handling pattern**: Migrating to `Result<T, E>` changes repository return types (non-breaking for Riverpod consumers, but affects data layer directly)

## Timeline & Priority

- **Phase 1 (Quick Wins)**: Database optimization, magic numbers extraction, deprecated fields removal (1-2 days)
- **Phase 2 (Core Fixes)**: Request deduplication, error handling, memory leaks (2-3 days)
- **Phase 3 (Architecture)**: Provider separation, dependency cleanup (2-3 days)

**Recommended approach**: Complete Phase 1-2 as bug fixes, then Phase 3 as architectural improvement once foundation is solid.
