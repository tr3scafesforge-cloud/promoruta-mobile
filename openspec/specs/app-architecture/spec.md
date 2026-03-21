# app-architecture Specification

## Purpose
Define and preserve the feature-first clean architecture boundaries for the mobile application.

## Requirements
### Requirement: No Legacy Presentation Layer
The codebase SHALL NOT contain the legacy `lib/presentation/` directory structure.

#### Scenario: No legacy files remain
- **WHEN** the codebase is inspected after architectural cleanup
- **THEN** no files exist in `lib/presentation/`

#### Scenario: Feature presentation is the single source of truth
- **WHEN** UI code is organized for advertiser, promoter, or shared flows
- **THEN** presentation code resides in feature-specific modules instead of a legacy global presentation layer

### Requirement: Dependency Isolation
The shared layer (`lib/shared/`) SHALL NOT import directly from feature domain modules (`lib/features/*/domain/`).

#### Scenario: Shared services use shared contracts
- **WHEN** shared infrastructure coordinates authentication, location, or synchronization concerns
- **THEN** it depends on shared contracts or infrastructure abstractions instead of feature domain interfaces

#### Scenario: Sync service uses injected delegates
- **WHEN** synchronization spans multiple domains
- **THEN** the sync service receives delegates through dependency injection rather than importing feature domain types directly

### Requirement: Provider Single Source of Truth
Providers shared across the app SHALL have exactly one canonical definition.

#### Scenario: Connectivity status provider is defined once
- **WHEN** features need network connectivity state
- **THEN** they read a single `connectivityStatusProvider` source of truth

### Requirement: Clean Architecture Compliance
The codebase SHALL maintain strict architectural boundaries across core, shared, and feature modules.

#### Scenario: Feature isolation verified
- **WHEN** imports are analyzed within a feature
- **THEN** features import from core and shared, but not from other feature domains unless a shared contract explicitly mediates the dependency

#### Scenario: Shared infrastructure remains reusable
- **WHEN** infrastructure code is reused across multiple features
- **THEN** it does not create feature-to-feature coupling through shared modules

### Requirement: Test Code Placement
Executable test files SHALL live under `test/` and SHALL NOT remain under `lib/`.

#### Scenario: Test files stored in test directory
- **WHEN** test-related Dart files are added for validation or debugging
- **THEN** they are created under `test/`

#### Scenario: Library tree remains production-only
- **WHEN** the `lib/` directory is scanned for Dart files
- **THEN** no `*_test.dart` files are present
