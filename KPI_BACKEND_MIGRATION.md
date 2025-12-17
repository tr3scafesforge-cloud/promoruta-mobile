# KPI Backend Migration Guide

## Current Status
Currently using **local calculations** for all KPI metrics (works offline).

## When Backend is Deployed

Follow these steps to switch to the hybrid approach (backend for investment, local for zones):

### Step 1: Update `lib/shared/providers/providers.dart`

**Uncomment the backend provider:**
```dart
// Remove the comment markers from lines 325-330
final kpiStatsProvider = FutureProvider.autoDispose<model.AdvertiserKpiStats>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return await repository.getKpiStats();
});
```

**Remove the local investment provider:**
```dart
// Delete or comment out lines 361-375 (totalInvestmentProvider)
```

### Step 2: Update `lib/features/advertiser/presentation/pages/advertiser_home_page.dart`

**Replace line 57:**
```dart
// Change from:
final totalInvestment = ref.watch(totalInvestmentProvider);

// To:
final kpiStatsAsync = ref.watch(kpiStatsProvider);
```

**Replace lines 87-96:**
```dart
// Change from:
Expanded(
  child: _StatCard(
    icon: Icons.attach_money_rounded,
    value: '\$${totalInvestment.toStringAsFixed(0)}',
    labelTop: widget.l10n.investment,
    labelBottom: widget.l10n.accumulated,
    iconColor: AppColors.secondary,
    backgroundColor: AppColors.secondary.withValues(alpha: .2),
  ),
),

// To:
Expanded(
  child: kpiStatsAsync.when(
    loading: () => _StatCard(
      icon: Icons.attach_money_rounded,
      value: '--',
      labelTop: widget.l10n.investment,
      labelBottom: widget.l10n.accumulated,
      iconColor: AppColors.secondary,
      backgroundColor: AppColors.secondary.withValues(alpha: .2),
    ),
    error: (error, stack) => _StatCard(
      icon: Icons.attach_money_rounded,
      value: '\$0',
      labelTop: widget.l10n.investment,
      labelBottom: widget.l10n.accumulated,
      iconColor: AppColors.secondary,
      backgroundColor: AppColors.secondary.withValues(alpha: .2),
    ),
    data: (kpiStats) => _StatCard(
      icon: Icons.attach_money_rounded,
      value: '\$${kpiStats.totalInvestment.toStringAsFixed(0)}',
      labelTop: widget.l10n.investment,
      labelBottom: widget.l10n.accumulated,
      iconColor: AppColors.secondary,
      backgroundColor: AppColors.secondary.withValues(alpha: .2),
    ),
  ),
),
```

### Step 3: Deploy Backend

Make sure the Laravel backend endpoint is deployed:
- Endpoint: `GET /api/advertiser/kpi-stats`
- Location: `app/Http/Controllers/Api/CampaignController.php:668-695`
- Route: `routes/api.php:86-88`

### Step 4: Test

1. Run the Flutter app
2. Login as an advertiser
3. Check the home page KPI cards:
   - Active Campaigns (local) ✅
   - Zones Covered This Week (local) ✅
   - Total Investment (from backend) ✅

## Benefits After Migration

- **Total Investment**: Authoritative from backend (includes payment data)
- **Zones Covered**: Fast local calculation (works offline)
- **Scalability**: Backend can add more KPIs without app updates
