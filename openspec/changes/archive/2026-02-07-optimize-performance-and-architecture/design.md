# Design Document: Performance & Architecture Optimization

## Context

The PromoRuta mobile application has accumulated several functional and performance issues as the codebase has grown:

1. **Performance Issues**: Database N+1 queries, undeduped polling, inefficient state mutations
2. **Resilience Issues**: Unsafe JSON parsing, race conditions in token refresh, missing error recovery
3. **Maintainability Issues**: Inconsistent error handling, scattered magic numbers, incomplete features
4. **Architecture Issues**: Feature-to-feature dependencies, massive provider file, violation of clean architecture

These issues create friction in development and risk in production (crashes, memory leaks, race conditions).

## Goals

**Goals:**
- Eliminate N+1 database queries and polling overlaps (>75% performance improvement in affected areas)
- Prevent crash-prone unsafe casts and force unwrapping
- Fix race condition in token refresh interceptor
- Establish consistent error handling pattern (Result<T, E>)
- Restore feature-first architecture with clear dependency boundaries
- Remove technical debt (deprecated fields, incomplete features, magic numbers)

**Non-Goals:**
- Redesign UI/UX
- Change API contract (backend changes are separate)
- Implement new features beyond what's necessary for fixes
- Add comprehensive test suite (that's separate from this change)
- Optimize beyond identified bottlenecks

## Architectural Decisions

### 1. Result<T, E> Type for Error Handling

**Decision**: Implement `Result<T, E>` sealed class (or abstract base) for consistent error handling across data layer.

**Rationale**:
- Current codebase has mixed error handling (try-catch, throws, silent failures, null returns)
- Forcing error handling at compile time via `Result` type prevents accidental error ignoring
- Functional programming style `.mapSuccess()`, `.fold()` reduces boilerplate in presentation layer
- Explicit error types in signature document what can fail

**Alternatives Considered**:
- **Exceptions only**: Simple but requires try-catch everywhere; hard to track expected errors. ❌
- **Null + throwable**: Doesn't distinguish between "not found" and "error". ❌
- **Either<L, R> from functional_programming package**: Adds external dependency for standard pattern. ❌

**Implementation**:
```dart
sealed class Result<T, E> {
  factory Result.success(T value) = Success<T, E>;
  factory Result.failure(E error) = Failure<T, E>;

  R fold<R>(R Function(T) onSuccess, R Function(E) onFailure);
  Result<U, E> mapSuccess<U>(U Function(T) f);
}

final class Success<T, E> implements Result<T, E> { ... }
final class Failure<T, E> implements Result<T, E> { ... }
```

### 2. Feature-Layer Providers vs Shared Providers

**Decision**: Move feature-specific providers (auth, campaign, location) to feature layers. Keep only infrastructure providers in shared layer.

**Rationale**:
- `lib/shared/providers/providers.dart` is 600+ lines, mixing unrelated concerns
- Creates implicit dependencies between features (auth depends on campaign, etc.)
- Violates feature-first architecture principle that features are isolated
- Shared layer should contain only cross-cutting infrastructure (DIO, Mapbox, Drift, Logger)

**Current State**:
```
shared/providers/providers.dart (600 lines, mixed concerns)
  ├── auth stuff
  ├── campaign stuff
  ├── location stuff
  ├── payment stuff
  ├── and more...
```

**Target State**:
```
shared/providers/providers.dart (100 lines, only infrastructure)
  ├── dioProvider
  ├── driftDatabaseProvider
  ├── loggerProvider
  ├── mapboxProvider
  └── etc...

features/auth/presentation/providers.dart
  ├── authRepositoryProvider
  └── authNotifierProvider

features/advertiser/campaign_management/presentation/providers.dart
  ├── campaignRepositoryProvider
  └── campaignNotifierProvider
```

**Rationale for this split**:
- Infrastructure providers are truly cross-cutting (used by all features)
- Feature providers are only used within feature boundaries
- Removes circular dependency risk

### 3. Request Deduplication Instead of Request Queuing

**Decision**: Implement deduplication (prevent simultaneous requests) rather than full request queuing.

**Rationale**:
- Live campaign polling shouldn't queue up old requests
- We want latest state, not all states processed in order
- If user polls every 10s and requests take 15s, we want: request 1 completes, request 2 executes immediately (not queue 3-10)
- Simpler to implement and understand than full async queue

**Implementation Pattern**:
```dart
class LiveCampaignNotifier {
  bool _isLoading = false;

  Future<void> refresh() async {
    if (_isLoading) return; // Deduplicate

    _isLoading = true;
    try {
      final result = await _repository.fetch();
      // update state
    } finally {
      _isLoading = false;
    }
  }
}
```

**Alternative Considered**:
- **Full async queue**: Process all requests in order. More complex, wrong semantics for polling. ❌
- **Cancel previous request**: Interrupts in-progress work. Better for UI, worse for background sync. ⚠️ (Keep for explicit user refresh, not timer-based)

### 4. Index-Based State Updates vs Immutable List Recreation

**Decision**: Use index-based updates with immutable copy semantics instead of `.map().toList()`.

**Rationale**:
- `.map()` iterates entire list; wasteful for single-item updates
- Creating new list with copy + index assignment is O(1) mentally and similar performance
- Immutable semantics are preserved
- More explicit what changed

**Current (Inefficient)**:
```dart
state = state.copyWith(
  alerts: state.alerts.map((a) => a.id == id ? a.copyWith(isRead: true) : a).toList()
);
```

**Target (Efficient)**:
```dart
final index = state.alerts.indexWhere((a) => a.id == id);
if (index != -1) {
  final newAlerts = [...state.alerts];
  newAlerts[index] = newAlerts[index].copyWith(isRead: true);
  state = state.copyWith(alerts: newAlerts);
}
```

### 5. Batch Database Queries via IN Clause

**Decision**: Replace loop-based per-item queries with single batch query using `IN (...)` clause.

**Rationale**:
- N+1 query pattern is well-known performance anti-pattern
- Loading 100 routes: N+1 = 101 queries → IN clause = 2 queries (1 routes + 1 batch GPS)
- ~98% reduction in round trips
- SQLite optimizes IN clauses internally

**Current (N+1)**:
```dart
for (final route in routes) {
  final gpsPoints = await _db.query('SELECT * FROM gps_points WHERE route_id = ?', [route.id]);
}
```

**Target (Batch)**:
```dart
final routeIds = routes.map((r) => r.id).toList();
final allGpsPoints = await _db.query(
  'SELECT * FROM gps_points WHERE route_id IN (${List.filled(routeIds.length, '?').join(',')})',
  routeIds
);
```

### 6. Transient vs Non-Transient Error Retry Logic

**Decision**: Implement exponential backoff retry only for transient errors; fail immediately for non-transient errors.

**Rationale**:
- Network timeouts usually recover; retrying helps
- 401 Unauthorized won't fix itself; retrying wastes user time
- Server errors (5xx) may recover; reasonable to retry
- Validation errors (422) are user input issues; retry won't help

**Classification**:
- **Transient**: Timeout, connection reset, 503 Service Unavailable, 429 Rate Limited
- **Non-Transient**: 401 Auth, 403 Forbidden, 404 Not Found, 422 Validation, 400 Bad Request

### 7. Mutex for Token Refresh Race Condition

**Decision**: Use async mutex (via `Mutex` or simple flag with waiting) to ensure only one token refresh occurs simultaneously.

**Rationale**:
- Multiple concurrent 401 responses can trigger simultaneous token refresh
- If two refresh requests send in parallel, second might use token from first before other requests retry
- Mutex ensures all requests wait for single refresh, then all proceed with new token
- Standard pattern in OAuth implementations

**Implementation**:
```dart
class TokenRefreshInterceptor {
  final Mutex _refreshMutex = Mutex();

  Future<void> _ensureValidToken() async {
    await _refreshMutex.protect(() async {
      if (_isTokenExpired()) {
        await _refreshToken();
      }
    });
  }
}
```

**Alternative**: Simple bool flag requires careful handling of concurrent access. Mutex is cleaner. ✓

## Risk Analysis

### Risk: Data Loss During Refactoring
**Severity**: High
**Mitigation**: Feature work is internal architecture. No data migrations needed. Git history preserved for rollback.

### Risk: Performance Regression from Changes
**Severity**: Medium
**Mitigation**: Benchmark before/after. Changes are targeted optimizations, not fundamental rewrites.

### Risk: Breaking API Consumers During Result<T> Migration
**Severity**: Low
**Mitigation**: Riverpod providers abstract repositories. Consumers don't change directly. Gradual migration possible.

### Risk: Merge Conflicts if Other Branches Modify providers.dart
**Severity**: Medium
**Mitigation**: Separate provider split into multiple targeted PRs. Coordinate with team on timing.

## Migration Plan

### Phase 1: Preparatory Work (1-2 days)
1. Create Result<T, E> type and error hierarchy (no refactoring yet)
2. Extract magic numbers to constants
3. Remove deprecated fields and incomplete features
4. All changes are additive; no breaking changes

**Rollback Risk**: Minimal (additive changes)

### Phase 2: Performance Optimizations (2-3 days)
1. Fix N+1 query with batch loading
2. Implement request deduplication
3. Fix state mutation efficiency
4. Add autoDispose to providers
5. Remove permission request delays

**Rollback Risk**: Low (localized changes to 3-4 files)

### Phase 3: Error Handling (2-3 days)
1. Migrate campaign repository to Result<T>
2. Fix unsafe JSON deserialization
3. Add structured error logging
4. Implement retry logic
5. Fix token refresh race condition

**Rollback Risk**: Medium (affects API boundary, but contained)

### Phase 4: Architecture Refactoring (2-3 days)
1. Move auth providers to feature layer
2. Separate monolithic providers file
3. Consolidate API response formats
4. Remove feature cross-dependencies

**Rollback Risk**: High (large refactoring), but can rollback independently

## Rollback Strategy

- **Phase 1-2**: Can rollback cleanly via Git revert; no data migration
- **Phase 3**: Can rollback via Git revert; clients might see temporary Result types, but providers insulate them
- **Phase 4**: Architecture changes are independent; can rollback largest providers.dart split if issues arise
- **Contingency**: If critical bug found after Phase 2, rollback and maintain on previous version while investigation occurs

## Testing Strategy

- **Existing Tests**: All existing tests should pass; these changes preserve behavior
- **New Tests**: Add tests for Result<T> type, retry logic, request deduplication
- **Benchmarking**: Measure before/after for N+1 query and state mutation timing
- **Integration Testing**: Test full flow (live campaign polling, permission request, token refresh)
- **Memory Profiling**: Verify autoDispose prevents memory leaks on repeated navigation

## Success Criteria

1. ✓ All database queries for GPS data complete in 2 queries instead of N+1
2. ✓ Live campaign polling prevents overlapping requests
3. ✓ No unsafe casts (`as`, `!` operator) remain in API parsing code
4. ✓ All repository methods return Result<T, AppError>
5. ✓ Token refresh prevents race conditions (verified via test)
6. ✓ Feature-specific providers moved to feature layers
7. ✓ All tests pass
8. ✓ Memory profiling shows stable cache behavior
9. ✓ No circular feature dependencies remain

## Timeline Estimate

- Phase 1: 1-2 days
- Phase 2: 2-3 days
- Phase 3: 2-3 days
- Phase 4: 2-3 days
- **Total**: 7-11 days, can be parallelized (3-5 days wall time with team)

## Open Questions

1. **API Contract**: Should we drop legacy API response format fallback or maintain backwards compatibility?
   - **Decision**: Document API contract with backend team; drop legacy support in next major version

2. **Retry Configuration**: Should retry counts and backoff durations be configurable?
   - **Decision**: Hardcode sensible defaults (3 retries, 1s-8s backoff); make configurable if needed later

3. **Error Logging Backend**: Should errors be sent to remote service (Sentry, etc.)?
   - **Decision**: Log to console in dev, no remote service yet (setup separately if needed)

4. **Batch Size Limits**: Should GPS point queries batch in chunks if > 1000 routes?
   - **Decision**: Start with single batch query; optimize further if performance issues remain
