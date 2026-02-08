# Change: Complete Payments and Ratings Features

## Why

The payments and ratings features are only ~20% complete with largely unimplemented payment gateway integration and rating workflows. These are critical for platform monetization and trust-building. The documented project spec mentions both as essential features but the mobile implementation is minimal.

## What Changes

### Payments Feature
- Implement payment data model and repository layer
- Create payment processing workflow with PagSeguro/Mercado Pago integration (Laravel backend handles transactions)
- Add payment history view with transaction details
- Implement payment status tracking (pending, completed, refunded, failed)
- Add payment method management UI

### Ratings Feature
- Implement bidirectional rating system (advertiser rates promoter, promoter rates advertiser)
- Create rating UI with star system and optional comments
- Add rating history and profile badges
- Implement rating notifications and disputes workflow
- Create rating aggregation (average rating, review count)

## Impact

- **Affected specs:** `payments`, `ratings` (new specs will be added to `specs/`)
- **Affected code:**
  - `lib/features/payments/` (complete implementation)
  - `lib/features/ratings/` (complete implementation)
  - `lib/shared/providers/` (payment and rating providers)
  - `lib/features/advertiser/` (payment history, campaign creation flow)
  - `lib/features/promotor/` (campaign completion with rating)
- **User-facing changes:**
  - New payment flow during campaign creation
  - Rating dialog after campaign completion
  - Rating profiles on user pages
  - Payment history page
- **Data model changes:** Adds `payments` and `ratings` tables to Drift database

## Validation

- Payment workflows integrate correctly with Laravel backend
- Ratings can be posted and retrieved without errors
- User cannot rate the same campaign twice
- Average rating calculations are correct
- Payment history shows all transactions accurately
