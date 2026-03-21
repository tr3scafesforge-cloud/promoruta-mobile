# Change: Refactor Architecture and Remove Legacy Code

## Why

The codebase currently contains 16 legacy files in `lib/presentation/` that violate the documented feature-first clean architecture. Additionally, the shared layer imports directly from feature domains (violating dependency rules), and duplicate providers exist. These issues create confusion about the source of truth and make the architecture harder to maintain and evolve.

## What Changes

- Remove legacy `lib/presentation/` folder and migrate any remaining functionality to feature-specific implementations
- Fix architectural violations: update `sync_service_impl.dart` to use interfaces instead of importing from features
- Remove duplicate `connectivityStatusProvider` definitions (keep one, remove the other)
- Remove test files from `lib/presentation/promotor/` that should be in `test/`
- Move or remove debug test pages (`simple_map_test.dart`, `polyline_test.dart`, `point_annotation_test.dart`)

## Impact

- **Affected specs:** `app-architecture`
- **Affected code:**
  - `lib/presentation/` (16 files, complete removal)
  - `lib/shared/data/services/sync_service_impl.dart` (refactored)
  - `lib/shared/providers/infrastructure_providers.dart` and `providers.dart` (deduplicated)
  - `lib/features/promotor/presentation/pages/` (test files removed)
- **Breaking changes:** None (architectural cleanup only)
- **Migration:** No user-facing impact; internal refactoring

## Validation

- No legacy presentation files remain in codebase
- All shared layer imports use repository interfaces, not feature implementations
- Dependency graph follows documented rules (no features → shared → features cycles)
- All test files are in `test/` directory, not `lib/`
