# Implementation Tasks: Refactor Architecture and Remove Legacy Code

## 1. Analysis and Planning
- [ ] 1.1 Audit all files in `lib/presentation/` and identify their current features
- [ ] 1.2 Map legacy functionality to feature-based equivalents
- [ ] 1.3 Identify any unique UI patterns or functionality not yet migrated to features
- [ ] 1.4 Document which legacy pages are duplicates vs. unique

## 2. Remove Legacy Presentation Files
- [ ] 2.1 Delete `lib/presentation/advertiser/pages/` (8 files)
- [ ] 2.2 Delete `lib/presentation/promotor/pages/` (3 files)
- [ ] 2.3 Delete `lib/presentation/home_screen.dart` and other root presentation files
- [ ] 2.4 Verify no remaining imports reference deleted files
- [ ] 2.5 Fix any broken imports in feature pages

## 3. Fix Architectural Violations in Sync Service
- [ ] 3.1 Refactor `sync_service_impl.dart` to accept repository interfaces via constructor injection
- [ ] 3.2 Remove direct imports from `features/advertiser/` and `features/promotor/`
- [ ] 3.3 Update `SyncService` interface to accept abstracted data source types
- [ ] 3.4 Update all calls to `SyncService` with appropriate repository instances
- [ ] 3.5 Add tests to verify SyncService doesn't import from features

## 4. Deduplicate Provider Definitions
- [ ] 4.1 Compare `connectivityStatusProvider` in `infrastructure_providers.dart:50` and `providers.dart:54`
- [ ] 4.2 Keep the more complete implementation, remove the duplicate
- [ ] 4.3 Verify all imports reference the single source of truth
- [ ] 4.4 Audit for other duplicate provider definitions

## 5. Move Test Files
- [ ] 5.1 Move `lib/presentation/promotor/simple_map_test.dart` to `test/features/location/`
- [ ] 5.2 Move `lib/presentation/promotor/polyline_test.dart` to `test/features/location/`
- [ ] 5.3 Move `lib/presentation/promotor/point_annotation_test.dart` to `test/features/location/`
- [ ] 5.4 Remove files from `lib/` after migration
- [ ] 5.5 Update any imports in test files if needed

## 6. Cleanup and Verification
- [ ] 6.1 Run `flutter pub get` and ensure no import errors
- [ ] 6.2 Run `flutter analyze` and fix any warnings
- [ ] 6.3 Verify dependency graph matches documented architecture
- [ ] 6.4 Run `flutter test` to ensure all tests pass
- [ ] 6.5 Review final folder structure against `openspec/project.md`
