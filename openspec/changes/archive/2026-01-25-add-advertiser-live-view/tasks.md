## 1. Domain Layer

- [x] 1.1 Create `LivePromoterLocation` model in `lib/features/advertiser/campaign_management/domain/models/`
- [x] 1.2 Create `CampaignAlert` model for execution events
- [x] 1.3 Create `AdvertiserLiveRepository` interface in `domain/repositories/`
- [x] 1.4 Create `GetLiveCampaignsUseCase` in `domain/use_cases/`

## 2. Data Layer

- [x] 2.1 Create `LiveCampaignRemoteDataSource` for API calls
- [x] 2.2 Implement `AdvertiserLiveRepositoryImpl` with polling support
- [x] 2.3 Add API endpoint integration for `/advertiser/live-campaigns` (with fallback to `/campaigns`)
- [x] 2.4 Add error handling and offline fallback

## 3. State Management

- [x] 3.1 Create `AdvertiserLiveNotifier` Riverpod provider
- [x] 3.2 Implement 10-second polling refresh timer
- [x] 3.3 Add campaign selection state management
- [x] 3.4 Add alert state management with unread count

## 4. Presentation Layer - Map View

- [x] 4.1 Replace placeholder map with Mapbox implementation
- [x] 4.2 Add promoter location markers (PointAnnotation)
- [x] 4.3 Add campaign route polylines (color-coded by campaign)
- [x] 4.4 Add coverage zone polygons (semi-transparent)
- [x] 4.5 Implement "center on promoter" functionality
- [x] 4.6 Implement "follow mode" for real-time tracking

## 5. Presentation Layer - Campaign List

- [x] 5.1 Implement `DraggableScrollableSheet` with campaign list
- [x] 5.2 Add filter chips (Active, Pending, No Signal)
- [x] 5.3 Create `PromoterListItem` widget with status indicators
- [x] 5.4 Implement campaign selection and map focus

## 6. Presentation Layer - Alerts

- [x] 6.1 Create `AlertCard` widget for event display
- [x] 6.2 Implement alerts tab in bottom sheet
- [x] 6.3 Add unread badge indicator

## 7. Localization

- [x] 7.1 Add English (en) strings for live view
- [x] 7.2 Add Spanish (es) translations
- [x] 7.3 Add Portuguese (pt) translations

## 8. Testing

- [x] 8.1 Unit tests for `LivePromoterLocation` model
- [x] 8.2 Unit tests for `AdvertiserLiveState`
- [x] 8.3 Unit tests for `CampaignAlert` model
- [x] 8.4 Unit tests for filter functionality

## 9. Integration

- [x] 9.1 Wire up providers in `shared/providers/providers.dart`
- [x] 9.2 Update `AdvertiserHomeScreen` to use new `AdvertiserLiveMapPage`
- [x] 9.3 Backend endpoint `/advertiser/live-campaigns` implemented
- [x] 9.4 Backend integration tests (16 tests in LiveCampaignsTest.php)

## Dependencies

- Tasks 1.x completed before 2.x (domain before data)
- Tasks 3.x completed in parallel with 2.x
- Tasks 4.x and 5.x completed after 3.x (state management)
- Tasks 7.x completed in parallel with 4.x-6.x
- Tasks 8.x completed after respective implementation tasks
- Task 9.x is final integration after all features complete

## Files Created

### Mobile (Flutter)
- `lib/features/advertiser/campaign_management/domain/models/live_campaign_models.dart`
- `lib/features/advertiser/campaign_management/domain/repositories/advertiser_live_repository.dart`
- `lib/features/advertiser/campaign_management/domain/use_cases/advertiser_live_use_cases.dart`
- `lib/features/advertiser/campaign_management/data/datasources/remote/advertiser_live_remote_data_source.dart`
- `lib/features/advertiser/campaign_management/data/repositories/advertiser_live_repository_impl.dart`
- `lib/features/advertiser/campaign_management/presentation/providers/advertiser_live_notifier.dart`
- `lib/features/advertiser/campaign_management/presentation/pages/advertiser_live_map_page.dart`
- `test/features/advertiser/campaign_management/domain/models/live_campaign_models_test.dart`

### Backend (Laravel)
- `tests/Feature/LiveCampaignsTest.php` - 16 integration tests for live campaigns endpoint

## Files Modified

### Mobile (Flutter)
- `lib/shared/providers/providers.dart` - Added advertiser live repository providers
- `lib/features/advertiser/presentation/pages/advertiser_home_screen.dart` - Updated to use new live page
- `lib/l10n/app_en.arb` - Added new localization strings
- `lib/l10n/app_es.arb` - Added Spanish translations
- `lib/l10n/app_pt.arb` - Added Portuguese translations

### Backend (Laravel)
- `routes/api.php` - Added `/advertiser/live-campaigns` route
- `app/Http/Controllers/Api/CampaignController.php` - Added `liveCampaigns()` method
