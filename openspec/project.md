# Project Context

## Purpose

Promoruta is a digital platform created to **formalize and modernize sound advertising (perifoneo)** in Uruguay. The platform connects local businesses with mobile sound promoters (vehicles equipped with loudspeakers) through a reliable, traceable, and regulated system, transforming a traditionally informal and unstructured service into a professional digital marketplace.

The objective is to digitalize campaign management, execution, and payment while introducing accountability, transparency, and scalability.

## Mission

Promoruta’s mission is to **professionalize and modernize sound advertising** by providing a technological platform that:

- Simplifies campaign creation for advertisers.
- Enables promoters to accept and execute campaigns reliably.
- Provides real-time GPS tracking and route validation.
- Ensures secure online payments.
- Builds trust through mutual ratings, traceability, and automation.

## Vision

To become the **leading digital platform for managing sound advertising campaigns** in public spaces—first in Uruguay, and later expanding to other Latin American countries where perifoneo remains a relevant advertising channel, such as Paraguay, Bolivia, and Peru.

## Core Value Proposition

- Digital governance of a traditionally informal market.
- Trust built on GPS traceability and execution validation.
- Accessible technology for small businesses and SMEs.
- Standardized pricing and transparent commissions.
- Scalable marketplace model with regional expansion potential.

## Revenue Model

### Direct Revenue

#### Campaign Commission
Promoruta charges a commission on each completed campaign.

Example:
- Campaign price: UYU 1,000  
- Platform commission (15%): UYU 150  

#### Premium Subscriptions
Monthly or annual subscription plans that offer:

- Priority access to high-demand schedules.
- Volume-based discounts.
- Advanced reporting and performance analytics.
- Priority customer support.

### Additional Services

- Professional audio production for advertising messages.
- Special political campaign management during election periods.
- Featured or highlighted campaigns within the app.

### In-App Advertising

- Moderated third-party advertising from local brands or complementary services.

## Expected Impact

### Local Businesses
- Affordable, location-based advertising.
- Simple, low-barrier access to sound advertising.
- Ideal for SMEs, retailers, and local entrepreneurs.

### Promoters
- Formalized income from an existing profession.
- Guaranteed digital payments.
- Reputation-based access to campaigns.
- Operational clarity and legal traceability.

### Citizens
- Reduced sound pollution through regulated schedules.
- Better control over public space usage.
- Increased accountability in urban sound advertising.

### Advertising Market
- Creation of a structured, digital-first platform.
- Opening of a new measurable advertising channel.
- Increased transparency in execution and pricing.

## Tech Stack

### Mobile Application (This Repository)

- **Framework:** Flutter 3.6.0+
- **Language:** Dart 3.6.0+
- **State Management:** Riverpod 2.6.1 with code generation
- **Routing:** go_router 16.1.0 with type-safe code generation
- **Local Database:** Drift 2.18.0 (SQLite wrapper)
- **HTTP Client:** Dio 5.9.0 with interceptors
- **Maps & GPS:** Mapbox Maps Flutter 2.3.0, Geolocator 13.0.2
- **Localization:** Flutter intl with ARB files (EN, ES, PT)
- **UI:** Material Design 3 with Google Fonts (RobotoFlex)

### Backend (Separate Repository)

- **Framework:** Laravel (PHP)
- **Database:** PostgreSQL
- **Authentication:** JWT with refresh tokens, 2FA support

### Key Dependencies

| Category | Package | Version |
|----------|---------|---------|
| State | flutter_riverpod | 2.6.1 |
| Routing | go_router | 16.1.0 |
| Database | drift | 2.18.0 |
| HTTP | dio | 5.9.0 |
| Maps | mapbox_maps_flutter | 2.3.0 |
| Location | geolocator | 13.0.2 |
| Storage | shared_preferences | 2.2.3 |
| Connectivity | connectivity_plus | 6.0.3 |
| Permissions | permission_handler | 11.3.0 |
| Environment | flutter_dotenv | 5.2.1 |
| Logging | logger | 2.0.2 |

## Architecture Patterns

### Feature-First Clean Architecture

The codebase follows a feature-first clean architecture with strict dependency rules:

```
lib/
├── app/                    # Application config (routes, startup)
├── core/                   # Shared constants, models, utilities
├── features/               # Feature modules (self-contained)
│   ├── advertiser/         # Advertiser-specific features
│   │   ├── campaign_creation/
│   │   ├── campaign_management/
│   │   └── promotor_selection/
│   ├── auth/               # Authentication
│   ├── location/           # Location services
│   ├── payments/           # Payment processing
│   ├── profile/            # User profile
│   ├── promotor/           # Promoter-specific features
│   │   ├── campaign_browsing/
│   │   ├── gps_tracking/
│   │   └── route_execution/
│   └── ratings/            # Rating system
├── shared/                 # Infrastructure (services, providers, widgets)
├── gen/                    # Generated code (DO NOT EDIT)
└── l10n/                   # Localization source files
```

### Feature Module Structure

Each feature follows this internal structure:

```
feature/
├── data/
│   ├── datasources/        # Local + remote data sources
│   ├── repositories/       # Repository implementations
│   └── models/             # DTOs and mappers
├── domain/
│   ├── models/             # Domain entities
│   ├── repositories/       # Repository interfaces
│   └── use_cases/          # Business logic
└── presentation/
    ├── pages/              # Full-screen views
    ├── widgets/            # Feature-specific components
    └── providers/          # Riverpod state management
```

### Dependency Rules

1. **Presentation** → **Domain** (use cases, models)
2. **Data** implements **Domain** interfaces
3. **Domain** has NO external dependencies
4. Features can depend on **Core** and **Shared**
5. Features should NOT depend on other features directly

### Design Patterns

- **API-first:** Mobile consumes Laravel REST API
- **Role-based access:** Advertiser, Promoter, Admin roles
- **Result type:** Error handling via Result<T, E> pattern
- **Provider pattern:** Riverpod for DI and state
- **Repository pattern:** Abstraction over data sources

## Coding Conventions

### Naming

- **Files:** snake_case (e.g., `campaign_service.dart`)
- **Classes:** PascalCase (e.g., `CampaignService`)
- **Variables/Functions:** camelCase (e.g., `getCampaigns()`)
- **Constants:** camelCase or SCREAMING_SNAKE_CASE for env vars
- **Providers:** camelCase with `Provider` suffix (e.g., `campaignServiceProvider`)

### Code Generation

Run after modifying annotated code:

```bash
# Full generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs

# Localization only
flutter gen-l10n
```

### Imports

- Use relative imports within the same feature
- Use package imports for cross-feature dependencies
- Generated files import: `package:promoruta/gen/...`

### State Management (Riverpod)

- Infrastructure providers in `lib/shared/providers/providers.dart`
- Feature providers in `lib/features/<feature>/presentation/providers/`
- Use `@riverpod` annotation for code generation
- Prefer `AsyncNotifier` for async state with mutations

### Error Handling

- Use `Result<T, E>` type for operations that can fail
- Propagate errors through use cases to presentation layer
- Display user-friendly messages via `toastification`

## Testing Strategy

### Test Structure

```
test/
├── features/               # Feature-specific tests
│   ├── auth/
│   ├── advertiser/
│   └── promotor/
├── core/                   # Core utility tests
├── shared/                 # Shared service tests
└── drift/                  # Database migration tests
```

### Test Types

- **Unit tests:** Core business logic and use cases
- **Widget tests:** UI component behavior
- **Integration tests:** Feature flows and API integration
- **Database tests:** Drift migrations and queries

### Running Tests

```bash
flutter test                    # All tests
flutter test --coverage         # With coverage report
flutter test test/path/file.dart  # Specific test
```

## Git Workflow

- **main:** Production-ready releases
- **develop:** Integration and testing (if used)
- **feature/*:** New features
- **fix/*:** Bug fixes
- **Commit messages:** Conventional commits (feat:, fix:, refactor:, docs:, etc.)

## Domain Context

Sound advertising (perifoneo) consists of vehicles equipped with loudspeakers circulating predefined routes while broadcasting audio advertisements. Promoruta introduces digital control, execution proof, and accountability to this traditional advertising method.

### Key Domain Concepts

- **Campaign:** An advertising request with audio, route, schedule, and budget
- **Promoter:** A driver with a vehicle equipped for sound advertising
- **Advertiser:** A business or individual creating campaigns
- **Route:** GPS-tracked path the promoter follows during execution
- **Execution:** Real-time GPS tracking validating campaign completion

## Constraints

- Compliance with local regulations regarding sound levels and operating hours
- GPS accuracy and mobile connectivity limitations
- Payment provider compliance and financial regulations
- Data privacy and user consent requirements (GDPR-like)
- Mapbox API rate limits (50k map loads, 100k routing requests/month free tier)
- Background location tracking battery impact

## External Dependencies

### Maps & Location

- **Mapbox Maps Flutter:** Interactive maps, offline support
- **Mapbox Routing API:** Route planning and optimization
- **OSRM:** Free routing fallback for cost management
- **Geolocator:** Device GPS access

### Backend Services

- **Laravel API:** REST endpoints for all business logic
- **JWT Authentication:** Token-based auth with refresh
- **Push Notifications:** (Planned) Firebase Cloud Messaging

### Environment Configuration

Required in `.env`:

```env
MAPBOX_ACCESS_TOKEN=your_mapbox_token
```

### Supported Platforms

- **Android:** SDK 21+ (Lollipop and above)
- **iOS:** 11.0+

### Localization

- English (en) - Default
- Spanish (es)
- Portuguese (pt)
