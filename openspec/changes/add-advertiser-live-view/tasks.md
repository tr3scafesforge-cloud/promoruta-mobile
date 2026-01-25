## 1. Domain Layer

- [ ] 1.1 Create `LivePromoterLocation` model in `lib/features/advertiser/campaign_management/domain/models/`
- [ ] 1.2 Create `CampaignAlert` model for execution events
- [ ] 1.3 Create `AdvertiserLiveRepository` interface in `domain/repositories/`
- [ ] 1.4 Create `GetLiveCampaignsUseCase` in `domain/use_cases/`

## 2. Data Layer

- [ ] 2.1 Create `LiveCampaignRemoteDataSource` for API calls
- [ ] 2.2 Implement `AdvertiserLiveRepositoryImpl` with polling support
- [ ] 2.3 Add API endpoint integration for `/advertiser/live-campaigns` (or equivalent)
- [ ] 2.4 Add error handling and offline fallback

## 3. State Management

- [ ] 3.1 Create `AdvertiserLiveNotifier` Riverpod provider
- [ ] 3.2 Implement 10-second polling refresh timer
- [ ] 3.3 Add campaign selection state management
- [ ] 3.4 Add alert state management with unread count

## 4. Presentation Layer - Map View

- [ ] 4.1 Replace placeholder map with Mapbox implementation
- [ ] 4.2 Add promoter location markers (PointAnnotation)
- [ ] 4.3 Add campaign route polylines (color-coded by campaign)
- [ ] 4.4 Add coverage zone polygons (semi-transparent)
- [ ] 4.5 Implement "center on promoter" functionality
- [ ] 4.6 Implement "follow mode" for real-time tracking

## 5. Presentation Layer - Campaign List

- [ ] 5.1 Implement `DraggableScrollableSheet` with campaign list
- [ ] 5.2 Add filter chips (Active, Pending, No Signal)
- [ ] 5.3 Create `PromoterListItem` widget with status indicators
- [ ] 5.4 Implement campaign selection and map focus

## 6. Presentation Layer - Alerts

- [ ] 6.1 Create `AlertCard` widget for event display
- [ ] 6.2 Implement alerts tab in bottom sheet
- [ ] 6.3 Add unread badge indicator

## 7. Localization

- [ ] 7.1 Add English (en) strings for live view
- [ ] 7.2 Add Spanish (es) translations
- [ ] 7.3 Add Portuguese (pt) translations

## 8. Testing

- [ ] 8.1 Unit tests for `LivePromoterLocation` model
- [ ] 8.2 Unit tests for `AdvertiserLiveNotifier`
- [ ] 8.3 Unit tests for `GetLiveCampaignsUseCase`
- [ ] 8.4 Widget tests for campaign list components

## 9. Integration

- [ ] 9.1 Wire up providers in `shared/providers/providers.dart`
- [ ] 9.2 Add feature flag for gradual rollout (optional)
- [ ] 9.3 End-to-end testing with live backend

## Dependencies

- Tasks 1.x must complete before 2.x (domain before data)
- Tasks 3.x can proceed in parallel with 2.x
- Tasks 4.x and 5.x depend on 3.x (state management)
- Tasks 7.x can proceed in parallel with 4.x-6.x
- Tasks 8.x should run after respective implementation tasks
- Task 9.x is final integration after all features complete
