# PromoRuta Mobile - Feature-First Architecture

## Overview

This project follows a **Feature-First Clean Architecture** pattern, where each feature is self-contained with its own data, domain, and presentation layers.

## Directory Structure

```
lib/
├── app/                          # Application-level configuration
│   └── routes/                   # App routing (go_router)
├── core/                         # Core business models & utilities
│   ├── constants/                # App-wide constants (colors, etc.)
│   ├── models/                   # Shared domain models (User, Config, etc.)
│   ├── utils/                    # Shared utilities (logger, permissions)
│   ├── theme.dart                # Material 3 theme
│   └── result.dart               # Result type for error handling
├── features/                     # Feature modules (feature-first)
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── local/        # Local data (Drift, SharedPrefs)
│   │   │   │   └── remote/       # Remote API calls (Dio)
│   │   │   ├── repositories/     # Repository implementations
│   │   │   └── models/           # DTOs, mappers
│   │   ├── domain/
│   │   │   ├── models/           # Feature-specific domain models
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   └── use_cases/        # Business logic use cases
│   │   └── presentation/
│   │       ├── pages/            # Full-screen pages
│   │       ├── widgets/          # Feature-specific widgets
│   │       └── providers/        # Feature-specific Riverpod providers
│   ├── advertiser/
│   │   ├── campaign_creation/    # Sub-feature
│   │   ├── campaign_management/
│   │   └── promotor_selection/
│   ├── promotor/
│   │   ├── campaign_browsing/
│   │   ├── gps_tracking/
│   │   └── route_execution/
│   ├── profile/
│   ├── payments/
│   └── ratings/
├── shared/                       # Truly shared infrastructure
│   ├── services/                 # Infrastructure services
│   │   ├── config_service.dart
│   │   ├── connectivity_service.dart
│   │   ├── notification_service.dart
│   │   ├── sync_service.dart
│   │   └── token_refresh_interceptor.dart
│   ├── datasources/
│   │   └── local/
│   │       └── db/               # Shared Drift database
│   ├── widgets/                  # Truly reusable widgets (buttons, cards)
│   └── providers/                # Shared infrastructure providers
└── gen/                          # Generated code (assets, l10n)
```

## Feature Structure Template

Each feature follows this structure:

```
features/{feature_name}/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── {feature}_local_data_source.dart
│   │   └── remote/
│   │       └── {feature}_remote_data_source.dart
│   ├── repositories/
│   │   └── {feature}_repository_impl.dart
│   └── models/
│       ├── {feature}_dto.dart         # Data Transfer Objects
│       └── {feature}_mappers.dart     # Model conversions
├── domain/
│   ├── models/
│   │   └── {feature}_model.dart       # Domain entities
│   ├── repositories/
│   │   └── {feature}_repository.dart  # Abstract interfaces
│   └── use_cases/
│       └── {feature}_use_cases.dart   # Business logic
└── presentation/
    ├── pages/
    │   └── {feature}_page.dart
    ├── widgets/
    │   └── {feature}_widget.dart      # Feature-specific UI
    └── providers/
        └── {feature}_providers.dart   # Riverpod state management
```

## Dependency Rules

1. **Presentation** depends on **Domain** (use cases, models)
2. **Data** implements **Domain** interfaces (repositories)
3. **Domain** has no dependencies (pure business logic)
4. Features can depend on **Core** and **Shared**
5. Features should NOT depend on other features directly

## State Management

- **Riverpod** for dependency injection and state management
- Each feature has its own `providers.dart` file
- Shared infrastructure providers in `lib/shared/providers/`

## Shared vs Feature Code

### Keep in Shared:
- Infrastructure services (connectivity, notifications, config)
- Database schema (Drift database)
- Reusable UI widgets (buttons, cards, app bars)
- Token refresh interceptor
- Sync service

### Move to Features:
- Feature-specific data sources
- Feature-specific repositories
- Feature-specific use cases
- Feature-specific UI pages
- Feature-specific providers

## Routing

- Type-safe routing using `go_router` with `go_router_builder`
- Routes defined in `lib/app/routes/app_router.dart`
- Each feature page uses `TypedGoRoute` annotation

## Testing Structure

```
test/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── {feature}/
├── core/
└── shared/
```

## Migration Status

- [x] Architecture documented
- [ ] Auth feature migrated
- [ ] Advertiser features migrated
- [ ] Promotor features migrated
- [ ] Shared folder reorganized
- [ ] Providers split by feature
- [ ] Tests restructured

## Adding a New Feature

1. Create feature folder: `lib/features/{feature_name}/`
2. Set up data/domain/presentation structure
3. Implement domain models and repository interface
4. Implement data layer (datasources, repository)
5. Create use cases for business logic
6. Build presentation layer (pages, widgets, providers)
7. Register providers in feature's `providers.dart`
8. Add routes in `app_router.dart`
9. Write tests for each layer
