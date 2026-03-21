# Specification Delta: App Architecture

## REMOVED Requirements
### Requirement: Legacy Presentation Layer
The legacy `lib/presentation/` directory structure that preceded feature-based organization SHALL be removed.

**Reason**: Violates documented feature-first clean architecture; creates confusion about source of truth; contains duplicate implementations.

**Migration**: All functionality is migrated to feature-specific presentation layers (`lib/features/*/presentation/`).

#### Scenario: No legacy files remain
- **WHEN** codebase is analyzed after refactoring
- **THEN** no files exist in `lib/presentation/` directory

#### Scenario: Duplicate features consolidated
- **WHEN** legacy and feature-based implementations exist for same UI
- **THEN** legacy version is removed, feature version is used exclusively

## MODIFIED Requirements
### Requirement: Dependency Isolation
The shared layer (`lib/shared/`) SHALL NOT import directly from feature domains (`lib/features/*/domain/`).

#### Scenario: Sync service uses repository interfaces
- **WHEN** SyncService needs to coordinate data from multiple features
- **THEN** it receives repository interfaces via dependency injection, not direct feature imports

#### Scenario: Provider duplication avoided
- **WHEN** a provider is defined in multiple files
- **THEN** only one source of truth exists; other definitions are removed

## ADDED Requirements
### Requirement: Clean Architecture Compliance
The codebase SHALL maintain strict architectural boundaries per documented feature-first pattern.

#### Scenario: Feature isolation verified
- **WHEN** analyzing imports in any feature
- **THEN** features import from shared and core, but NOT from other features

#### Scenario: Test files in correct location
- **WHEN** looking for test code
- **THEN** all test files are located in `test/` directory, none in `lib/`
