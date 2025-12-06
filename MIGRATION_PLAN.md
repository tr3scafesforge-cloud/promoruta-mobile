# Feature-First Architecture Migration Plan

## Migration Strategy

This document outlines the step-by-step plan to migrate from the current hybrid architecture to a consistent feature-first structure.

## Phase 1: Analysis & Preparation

### Code Distribution Analysis

#### Current State (`lib/shared/`):

**Datasources (Local):**
- `auth_local_data_source.dart` → Move to `features/auth/data/datasources/local/`
- `campaign_local_data_source.dart` → Move to `features/advertiser/campaign_management/data/datasources/local/`
- `gps_local_data_source.dart` → Move to `features/promotor/gps_tracking/data/datasources/local/`
- `user_local_data_source.dart` → Move to `features/profile/data/datasources/local/`
- `db/database.dart` → **KEEP in shared/** (database schema is infrastructure)

**Datasources (Remote):**
- `auth_remote_data_source.dart` → Move to `features/auth/data/datasources/remote/`
- `campaign_remote_data_source.dart` → Move to `features/advertiser/campaign_management/data/datasources/remote/`
- `gps_remote_data_source.dart` → Move to `features/promotor/gps_tracking/data/datasources/remote/`
- `media_remote_data_source.dart` → Move to `features/advertiser/campaign_creation/data/datasources/remote/`
- `user_remote_data_source.dart` → Move to `features/profile/data/datasources/remote/`

**Repositories:**
- `auth_repository.dart` (interface) → Move to `features/auth/domain/repositories/`
- `auth_repository_impl.dart` → Move to `features/auth/data/repositories/`
- `campaign_repository.dart` → Move to `features/advertiser/campaign_management/domain/repositories/`
- `campaign_repository_impl.dart` → Move to `features/advertiser/campaign_management/data/repositories/`
- `gps_repository.dart` → Move to `features/promotor/gps_tracking/domain/repositories/`
- `gps_repository_impl.dart` → Move to `features/promotor/gps_tracking/data/repositories/`
- `media_repository.dart` → Move to `features/advertiser/campaign_creation/domain/repositories/`
- `user_repository.dart` → Move to `features/profile/domain/repositories/`

**Use Cases:**
- `auth_use_cases.dart` → Move to `features/auth/domain/use_cases/`
- `campaign_use_cases.dart` → Move to `features/advertiser/campaign_management/domain/use_cases/`
- `base_use_case.dart` → **KEEP in shared/** (base abstraction)

**Models:**
- `campaign_mappers.dart` → Move to `features/advertiser/campaign_management/data/models/`
- `campaign_ui.dart` → Move to `features/advertiser/campaign_management/presentation/models/`

**Services (ALL STAY in shared/):**
- `config_service.dart` ✓
- `connectivity_service.dart` ✓
- `notification_service.dart` ✓
- `sync_service.dart` ✓
- `token_refresh_interceptor.dart` ✓

**Widgets:**
- `advertiser_app_bar.dart` → Move to `features/advertiser/presentation/widgets/`
- `advertiser_search_filter_bar.dart` → Move to `features/advertiser/presentation/widgets/`
- `promoter_app_bar.dart` → Move to `features/promotor/presentation/widgets/`
- `app_card.dart` → **KEEP in shared/** (generic widget)
- `custom_button.dart` → **KEEP in shared/** (generic widget)
- `multi_switch.dart` → **KEEP in shared/** (generic widget)
- `bottom_navigation_item.dart` → **KEEP in shared/** (generic widget)
- `permission_card.dart` → Move to `features/auth/presentation/widgets/`
- `profile_widgets.dart` → Move to `features/profile/presentation/widgets/`

#### Current State (`lib/presentation/`):

**Advertiser Pages:**
- All files in `presentation/advertiser/pages/` → Move to appropriate feature folders:
  - `advertiser_campaigns_page.dart` → `features/advertiser/campaign_management/presentation/pages/`
  - `advertiser_history_page.dart` → `features/advertiser/campaign_management/presentation/pages/`
  - `advertiser_home_page.dart` → `features/advertiser/presentation/pages/`
  - `advertiser_live_page.dart` → `features/advertiser/campaign_management/presentation/pages/`
  - `advertiser_profile_page.dart` → `features/profile/presentation/pages/`
  - `advertiser_security_settings_page.dart` → `features/profile/presentation/pages/`
  - `change_password_page.dart` → `features/profile/presentation/pages/`
  - `language_settings_page.dart` → `features/profile/presentation/pages/`
  - `payment_methods_page.dart` → `features/payments/presentation/pages/`
  - `two_factor_auth_page.dart` → `features/profile/presentation/pages/`
  - `user_profile_page.dart` → `features/profile/presentation/pages/`
- `advertiser_home_screen.dart` → `features/advertiser/presentation/pages/`

**Promotor Pages:**
- All files in `presentation/promotor/pages/` → Move to appropriate features:
  - `promoter_active_page.dart` → `features/promotor/route_execution/presentation/pages/`
  - `promoter_earnings_page.dart` → `features/promotor/presentation/pages/`
  - `promoter_home_page.dart` → `features/promotor/presentation/pages/`
  - `promoter_nearby_page.dart` → `features/promotor/campaign_browsing/presentation/pages/`
  - `promoter_profile_page.dart` → `features/profile/presentation/pages/`
  - `promoter_user_profile_page.dart` → `features/profile/presentation/pages/`
- `promoter_home_screen.dart` → `features/promotor/presentation/pages/`

**Providers:**
- `permission_provider.dart` → Move to `features/auth/presentation/providers/`

#### Current State (`lib/features/auth/`):

**Flat Files (need layering):**
- `choose_role.dart` → Move to `features/auth/presentation/pages/choose_role_page.dart`
- `login.dart` → Move to `features/auth/presentation/pages/login_page.dart`
- `onboarding_page_view.dart` → Move to `features/auth/presentation/pages/onboarding_page.dart`
- `permissions.dart` → Move to `features/auth/presentation/pages/permissions_page.dart`
- `start_page.dart` → Move to `features/auth/presentation/pages/start_page.dart`

## Phase 2: Feature-by-Feature Migration

### Step 1: Auth Feature (Priority 1)

**1.1 Create structure:**
```
features/auth/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   └── repositories/
├── domain/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

**1.2 Move files:**
- Move `shared/datasources/local/auth_local_data_source.dart`
- Move `shared/datasources/remote/auth_remote_data_source.dart`
- Move `shared/repositories/auth_repository.dart` to domain/
- Move `shared/repositories/auth_repository_impl.dart` to data/
- Move `shared/use_cases/auth_use_cases.dart`
- Move all auth pages from `features/auth/*.dart`
- Move `presentation/providers/permission_provider.dart`
- Move `shared/widgets/permission_card.dart`

**1.3 Create providers file:**
- `features/auth/presentation/providers/auth_providers.dart`

**1.4 Update imports**

### Step 2: Profile Feature (Priority 2)

**2.1 Create structure:**
```
features/profile/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   └── repositories/
├── domain/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

**2.2 Move files:**
- Move `shared/datasources/local/user_local_data_source.dart`
- Move `shared/datasources/remote/user_remote_data_source.dart`
- Move `shared/repositories/user_repository.dart`
- Move all profile-related pages from `presentation/advertiser/pages/` and `presentation/promotor/pages/`
- Move `shared/widgets/profile_widgets.dart`

**2.3 Create providers file:**
- `features/profile/presentation/providers/profile_providers.dart`

### Step 3: Advertiser Features (Priority 3)

#### 3.1 Campaign Management
```
features/advertiser/campaign_management/
├── data/
│   ├── datasources/local/
│   ├── datasources/remote/
│   ├── repositories/
│   └── models/
├── domain/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    ├── pages/
    └── providers/
```

**Move:**
- `shared/datasources/local/campaign_local_data_source.dart`
- `shared/datasources/remote/campaign_remote_data_source.dart`
- `shared/repositories/campaign_repository.dart`
- `shared/repositories/campaign_repository_impl.dart`
- `shared/use_cases/campaign_use_cases.dart`
- `shared/models/campaign_mappers.dart`
- `shared/models/campaign_ui.dart`
- Pages: `advertiser_campaigns_page.dart`, `advertiser_history_page.dart`, `advertiser_live_page.dart`

#### 3.2 Campaign Creation
```
features/advertiser/campaign_creation/
├── data/
│   ├── datasources/remote/
│   └── repositories/
├── domain/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    └── pages/
        └── create_campaign_page.dart (already exists)
```

**Move:**
- `shared/datasources/remote/media_remote_data_source.dart`
- `shared/repositories/media_repository.dart`

#### 3.3 Advertiser Root
```
features/advertiser/
└── presentation/
    ├── pages/
    │   ├── advertiser_home_screen.dart
    │   └── advertiser_home_page.dart
    └── widgets/
        ├── advertiser_app_bar.dart
        └── advertiser_search_filter_bar.dart
```

### Step 4: Promotor Features (Priority 4)

#### 4.1 GPS Tracking
```
features/promotor/gps_tracking/
├── data/
│   ├── datasources/local/
│   ├── datasources/remote/
│   └── repositories/
├── domain/
│   ├── repositories/
│   └── use_cases/
└── presentation/
```

**Move:**
- `shared/datasources/local/gps_local_data_source.dart`
- `shared/datasources/remote/gps_remote_data_source.dart`
- `shared/repositories/gps_repository.dart`
- `shared/repositories/gps_repository_impl.dart`

#### 4.2 Campaign Browsing
```
features/promotor/campaign_browsing/
└── presentation/
    └── pages/
        └── promoter_nearby_page.dart
```

#### 4.3 Route Execution
```
features/promotor/route_execution/
└── presentation/
    └── pages/
        └── promoter_active_page.dart
```

#### 4.4 Promotor Root
```
features/promotor/
└── presentation/
    ├── pages/
    │   ├── promoter_home_screen.dart
    │   ├── promoter_home_page.dart
    │   └── promoter_earnings_page.dart
    └── widgets/
        └── promoter_app_bar.dart
```

### Step 5: Payments Feature (Priority 5)

```
features/payments/
└── presentation/
    └── pages/
        └── payment_methods_page.dart
```

## Phase 3: Cleanup & Reorganization

### Step 6: Reorganize Shared Folder

**Final `lib/shared/` structure:**
```
shared/
├── datasources/
│   └── local/
│       └── db/                    # Drift database only
│           ├── database.dart
│           ├── database.g.dart
│           ├── db_migration.dart
│           └── entities/
├── services/
│   ├── config_service.dart
│   ├── connectivity_service.dart
│   ├── connectivity_service_impl.dart
│   ├── notification_service.dart
│   ├── overlay_notification_service.dart
│   ├── sync_service.dart
│   ├── sync_service_impl.dart
│   └── token_refresh_interceptor.dart
├── widgets/
│   ├── app_card.dart
│   ├── bottom_navigation_item.dart
│   ├── custom_button.dart
│   └── multi_switch.dart
├── use_cases/
│   └── base_use_case.dart
├── providers/
│   └── shared_providers.dart      # Only infrastructure providers
└── shared.dart
```

### Step 7: Split Providers

**Create feature-specific provider files:**
- `features/auth/presentation/providers/auth_providers.dart`
- `features/profile/presentation/providers/profile_providers.dart`
- `features/advertiser/campaign_management/presentation/providers/campaign_providers.dart`
- `features/advertiser/campaign_creation/presentation/providers/campaign_creation_providers.dart`
- `features/promotor/gps_tracking/presentation/providers/gps_providers.dart`

**Keep in `shared/providers/shared_providers.dart`:**
- Database provider
- Dio provider
- Config service provider
- Connectivity service provider
- Notification service provider
- Sync service provider

## Phase 4: Update References

### Step 8: Update Imports

Use find & replace for import statements:
- `import 'package:promoruta_mobile/shared/datasources/local/auth_local_data_source.dart'`
  → `import 'package:promoruta_mobile/features/auth/data/datasources/local/auth_local_data_source.dart'`
- (Continue for all moved files)

### Step 9: Update Barrel Files

Create `feature_name.dart` export files for each feature:
```dart
// features/auth/auth.dart
export 'data/datasources/local/auth_local_data_source.dart';
export 'data/datasources/remote/auth_remote_data_source.dart';
export 'data/repositories/auth_repository_impl.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/use_cases/auth_use_cases.dart';
export 'presentation/providers/auth_providers.dart';
```

## Phase 5: Testing & Validation

### Step 10: Verify Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter build apk --debug
```

### Step 11: Test Application

- Test all auth flows
- Test advertiser flows
- Test promotor flows
- Test profile management
- Verify offline support still works

## Execution Order

1. ✅ Document architecture (ARCHITECTURE.md)
2. ✅ Create migration plan (this file)
3. Auth feature migration
4. Profile feature migration
5. Advertiser features migration
6. Promotor features migration
7. Payments feature migration
8. Shared folder cleanup
9. Provider splitting
10. Import updates
11. Build verification
12. Testing

## Rollback Plan

- Keep git commits atomic (one feature at a time)
- Each phase should compile independently
- Tag working states: `migration/auth-complete`, `migration/profile-complete`, etc.
- If issues arise, revert to previous tag

## Estimated Impact

**Files to move:** ~50 files
**Import statements to update:** ~150-200
**New directories:** ~30
**Files to delete:** ~10 (old locations)

## Notes

- Keep `lib/core/models/` for truly shared domain models (User, Config, GPSPoint, Route, Campaign base)
- Database entities stay in `shared/datasources/local/db/entities/`
- Each feature exports a barrel file for easier imports
- Providers are organized by feature, not centralized
