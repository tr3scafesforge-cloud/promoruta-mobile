# Implementation Tasks: Complete Payments and Ratings

## 1. Payments Feature Implementation

### 1.1 Data Layer
- [ ] 1.1.1 Create `Payment` domain model with id, campaignId, amount, status, method, timestamp
- [ ] 1.1.2 Create Drift migration for `payments` table
- [ ] 1.1.3 Implement `PaymentLocalDataSource` for offline persistence
- [ ] 1.1.4 Implement `PaymentRemoteDataSource` for API calls
- [ ] 1.1.5 Implement `PaymentRepositoryImpl` with offline fallback

### 1.2 Domain Layer
- [ ] 1.2.1 Create `PaymentRepository` interface
- [ ] 1.2.2 Create use cases: `InitiatePaymentUseCase`, `GetPaymentStatusUseCase`, `GetPaymentHistoryUseCase`

### 1.3 Presentation Layer
- [ ] 1.3.1 Create `paymentNotifier` for state management
- [ ] 1.3.2 Create `PaymentMethodSelectionPage` (select credit card, debit, wallet)
- [ ] 1.3.3 Create `PaymentProcessingPage` with status indicator
- [ ] 1.3.4 Create `PaymentHistoryPage` with transaction list
- [ ] 1.3.5 Integrate payment flow into `campaign_creation` feature (payment before submission)
- [ ] 1.3.6 Add payment status indicators in campaign detail pages

### 1.4 Backend Integration
- [ ] 1.4.1 Define Payment API endpoints in Dio client (POST /campaigns/{id}/pay, GET /payments/{id})
- [ ] 1.4.2 Implement payment retry logic with exponential backoff
- [ ] 1.4.3 Handle payment failure scenarios with user-friendly error messages

### 1.5 Testing
- [ ] 1.5.1 Write unit tests for payment use cases
- [ ] 1.5.2 Write widget tests for payment UI pages
- [ ] 1.5.3 Add payment history query tests

## 2. Ratings Feature Implementation

### 2.1 Data Layer
- [ ] 2.1.1 Create `Rating` domain model with id, campaignId, authorId, targetId, rating (1-5), comment, timestamp
- [ ] 2.1.2 Create `RatingAggregate` model (average, count, reviews)
- [ ] 2.1.3 Create Drift migration for `ratings` table
- [ ] 2.1.4 Implement `RatingLocalDataSource` for offline persistence
- [ ] 2.1.5 Implement `RatingRemoteDataSource` for API calls
- [ ] 2.1.6 Implement `RatingRepositoryImpl` with offline fallback

### 2.2 Domain Layer
- [ ] 2.2.1 Create `RatingRepository` interface
- [ ] 2.2.2 Create use cases: `SubmitRatingUseCase`, `GetRatingsForUserUseCase`, `GetAverageRatingUseCase`

### 2.3 Presentation Layer
- [ ] 2.3.1 Create `ratingNotifier` for state management
- [ ] 2.3.2 Create `RatingDialog` widget with star rating and comment input
- [ ] 2.3.3 Create `UserRatingsPage` showing received ratings and profile score
- [ ] 2.3.4 Create `RatingBadges` widget for profile display
- [ ] 2.3.5 Integrate rating dialog into `route_execution` (promoter rates advertiser on completion)
- [ ] 2.3.6 Integrate rating dialog into advertiser campaign view (advertiser rates promoter)
- [ ] 2.3.7 Add rating display on user profiles

### 2.4 Backend Integration
- [ ] 2.4.1 Define Rating API endpoints (POST /campaigns/{id}/rate, GET /users/{id}/ratings)
- [ ] 2.4.2 Add validation: prevent duplicate ratings for same campaign
- [ ] 2.4.3 Implement rating aggregation calculation

### 2.5 Testing
- [ ] 2.5.1 Write unit tests for rating use cases
- [ ] 2.5.2 Write widget tests for rating dialog and profile pages
- [ ] 2.5.3 Add validation test for duplicate rating prevention

## 3. Integration and Sync
- [ ] 3.1 Update `SyncService` to include payment and rating sync
- [ ] 3.2 Add payment/rating batch sync to `campaign_execution_notifier`
- [ ] 3.3 Verify offline campaigns can be rated and paid for when reconnected

## 4. Testing and Validation
- [ ] 4.1 Integration test: complete campaign → pay → rate flow
- [ ] 4.2 Verify payment history shows correct transactions
- [ ] 4.3 Verify user ratings appear on profile after submission
- [ ] 4.4 Test offline payment/rating workflow with sync
- [ ] 4.5 Run full test suite and fix failures
