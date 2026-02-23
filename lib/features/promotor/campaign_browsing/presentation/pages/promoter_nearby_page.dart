import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_query_params.dart';
import 'package:promoruta/shared/providers/location_provider.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

// Filter types enum
enum CampaignFilter {
  all,
  urgent,
  nearby,
  bestPaid,
}

// Provider for campaign filter parameters
final campaignFilterParamsProvider =
    StateProvider.autoDispose<CampaignQueryParams>((ref) {
  return const CampaignQueryParams(perPage: 15);
});

// Provider for selected filter tab
final selectedFilterProvider = StateProvider.autoDispose<CampaignFilter>((ref) {
  return CampaignFilter.all;
});

// Provider for user location
final userLocationProvider = FutureProvider.autoDispose<LatLng?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);

  // Check if location services are enabled
  final isEnabled = await locationService.isLocationServiceEnabled();
  if (!isEnabled) {
    return null;
  }

  // Request location permission if not granted
  final hasPermission = await locationService.hasLocationPermission();
  if (!hasPermission) {
    final granted = await locationService.requestLocationPermission();
    if (!granted) {
      return null;
    }
  }

  // Get current location
  return await locationService.getCurrentLocation();
});

// Provider for filtered campaigns based on selected tab
final filteredCampaignsProvider =
    FutureProvider.autoDispose<List<Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  final selectedFilter = ref.watch(selectedFilterProvider);
  final userLocation = await ref.watch(userLocationProvider.future);

  CampaignQueryParams params;

  switch (selectedFilter) {
    case CampaignFilter.all:
      params = const CampaignQueryParams(
        perPage: 15,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );
      break;

    case CampaignFilter.urgent:
      params = const CampaignQueryParams(
        perPage: 15,
        upcoming: true,
        sortBy: 'start_time',
        sortOrder: 'asc',
      );
      break;

    case CampaignFilter.nearby:
      if (userLocation != null) {
        params = CampaignQueryParams(
          perPage: 15,
          lat: userLocation.latitude,
          lng: userLocation.longitude,
          radius: 10, // 10km radius
          sortBy: 'start_time',
          sortOrder: 'asc',
        );
      } else {
        // Fallback to all campaigns if location not available
        params = const CampaignQueryParams(
          perPage: 15,
          sortBy: 'created_at',
          sortOrder: 'desc',
        );
      }
      break;

    case CampaignFilter.bestPaid:
      params = const CampaignQueryParams(
        perPage: 15,
        sortBy: 'suggested_price',
        sortOrder: 'desc',
      );
      break;
  }

  return await getCampaignsUseCase(params);
});

class PromoterNearbyPage extends ConsumerStatefulWidget {
  const PromoterNearbyPage({super.key});

  @override
  ConsumerState<PromoterNearbyPage> createState() => _PromoterNearbyPageState();
}

class _PromoterNearbyPageState extends ConsumerState<PromoterNearbyPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    final filter = CampaignFilter.values[index];
    ref.read(selectedFilterProvider.notifier).state = filter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final campaignsAsync = ref.watch(filteredCampaignsProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

    final isLoading = campaignsAsync.isLoading;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: l10n.searchCampaigns,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            filled: true,
            fillColor: isLoading ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.activeCampaignColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Location status indicator (only for nearby filter)
        if (selectedFilter == CampaignFilter.nearby)
          userLocationAsync.when(
            loading: () => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.gettingYourLocation,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.locationUnavailableEnableServices,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            data: (location) {
              if (location == null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_off,
                          color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.locationPermissionRequired,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.showingCampaignsWithinRadius,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        if (selectedFilter == CampaignFilter.nearby) const SizedBox(height: 16),

        // Tab switcher
        IgnorePointer(
          ignoring: isLoading,
          child: Opacity(
            opacity: isLoading ? 0.5 : 1.0,
            child: MultiSwitch(
              options: [
                l10n.campaignFilterAll,
                l10n.campaignFilterUrgent,
                l10n.campaignFilterNearby,
                l10n.campaignFilterBestPaid,
              ],
              initialIndex: selectedFilter.index,
              onChanged: _onTabChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Content area - show loading or data
        campaignsAsync.when(
          loading: () => Column(
            children: [
              // Map section placeholder
              Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: SizedBox(
                  height: 250,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.activeCampaignColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Loading text
              Text(
                l10n.loadingCampaigns,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          error: (error, stack) => Column(
            children: [
              const SizedBox(height: 32),
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading campaigns: $error',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          data: (campaigns) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map section
              const _MapSection(),
              const SizedBox(height: 24),

              // Campaign list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.availableCampaignsCount(campaigns.length),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campaign cards or empty state
              if (campaigns.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.campaign_outlined,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noCampaignsFound,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...campaigns.asMap().entries.map((entry) {
                  final campaign = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < campaigns.length - 1 ? 12 : 0,
                    ),
                    child: _CampaignCard(
                      campaign: campaign,
                      userLocation: userLocationAsync.value,
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: AppColors.activeCampaignColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.viewOnMap,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.mapLocationRealTime,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends ConsumerWidget {
  final Campaign campaign;
  final LatLng? userLocation;

  const _CampaignCard({
    required this.campaign,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locationService = ref.watch(locationServiceProvider);

    // Check if campaign is urgent (bid deadline is within 3 hours)
    final now = DateTime.now();
    final timeUntilDeadline = campaign.bidDeadline.difference(now);
    final isUrgent =
        timeUntilDeadline.inHours < 3 && timeUntilDeadline.inHours >= 0;
    final urgencyMessage =
        isUrgent ? l10n.closesInHours(timeUntilDeadline.inHours) : null;

    // Calculate distance from user location if available
    double? distanceFromUser;
    if (userLocation != null && campaign.routeCoordinates.isNotEmpty) {
      final campaignLocation = LatLng(
        campaign.routeCoordinates.first.lat,
        campaign.routeCoordinates.first.lng,
      );
      distanceFromUser =
          locationService.calculateDistance(userLocation!, campaignLocation) /
              1000; // Convert to km
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and location
            Text(
              campaign.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              campaign.description ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    campaign.zone,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (distanceFromUser != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.activeCampaignColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.kmAway(distanceFromUser.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.activeCampaignColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Campaign details
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    value: '${campaign.distance.toStringAsFixed(1)}km',
                    label: l10n.route,
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    value: '${campaign.audioDuration}s',
                    label: l10n.audio,
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    value: '\$${campaign.suggestedPrice.toStringAsFixed(2)}',
                    label: l10n.budget,
                  ),
                ),
              ],
            ),

            // Urgency message
            if (urgencyMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                urgencyMessage,
                style: TextStyle(
                  color: AppColors.deepOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeCampaignColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${l10n.acceptCampaign}: ${campaign.title} (WIP)')),
                  );
                },
                child: Text(
                  l10n.acceptCampaign,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String value;
  final String label;

  const _DetailItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
