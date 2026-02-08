# Implementation Tasks: Refactor Architecture and Remove Legacy Code

## 1. Analysis and Planning
- [x] 1.1 Audit all files in `lib/presentation/` and identify their current features
- [x] 1.2 Map legacy functionality to feature-based equivalents
- [x] 1.3 Identify any unique UI patterns or functionality not yet migrated to features
- [x] 1.4 Document which legacy pages are duplicates vs. unique

## 2. Remove Legacy Presentation Files
- [x] 2.1 Delete `lib/presentation/advertiser/pages/` (8 files)
- [x] 2.2 Delete `lib/presentation/promotor/pages/` (3 files)
- [x] 2.3 Delete `lib/presentation/home_screen.dart` and other root presentation files
- [x] 2.4 Verify no remaining imports reference deleted files
- [x] 2.5 Fix any broken imports in feature pages

## 3. Fix Architectural Violations in Sync Service
- [x] 3.1 Refactor `sync_service_impl.dart` to accept repository interfaces via constructor injection
- [x] 3.2 Remove direct imports from `features/advertiser/` and `features/promotor/`
- [x] 3.3 Update `SyncService` interface to accept abstracted data source types
- [x] 3.4 Update all calls to `SyncService` with appropriate repository instances
- [x] 3.5 Add tests to verify SyncService doesn't import from features

## 4. Deduplicate Provider Definitions
- [x] 4.1 Compare `connectivityStatusProvider` in `infrastructure_providers.dart:50` and `providers.dart:54`
- [x] 4.2 Keep the more complete implementation, remove the duplicate
- [x] 4.3 Verify all imports reference the single source of truth
- [x] 4.4 Audit for other duplicate provider definitions

## 5. Move Test Files
- [x] 5.1 Move `lib/presentation/promotor/simple_map_test.dart` to `test/features/location/`
- [x] 5.2 Move `lib/presentation/promotor/polyline_test.dart` to `test/features/location/`
- [x] 5.3 Move `lib/presentation/promotor/point_annotation_test.dart` to `test/features/location/`
- [x] 5.4 Remove files from `lib/` after migration
- [x] 5.5 Update any imports in test files if needed

## 6. Cleanup and Verification
- [x] 6.1 Run `flutter pub get` and ensure no import errors
- [x] 6.2 Run `flutter analyze` and fix any warnings
- [x] 6.3 Verify dependency graph matches documented architecture
- [x] 6.4 Run `flutter test` to ensure all tests pass
- [x] 6.5 Review final folder structure against `openspec/project.md`
