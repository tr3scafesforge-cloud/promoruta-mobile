import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/models/live_campaign_models.dart';
import 'package:promoruta/features/advertiser/campaign_management/presentation/providers/advertiser_live_notifier.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:promoruta/shared/providers/map_style_provider.dart';
import 'package:promoruta/shared/widgets/map_style_picker.dart';

/// Provider for the advertiser live notifier
final advertiserLiveProvider =
    StateNotifierProvider<AdvertiserLiveNotifier, AdvertiserLiveState>((ref) {
  final repository = ref.watch(advertiserLiveRepositoryProvider);
  return AdvertiserLiveNotifier(repository);
});

/// Advertiser live campaign view with real-time map
class AdvertiserLiveMapPage extends ConsumerStatefulWidget {
  const AdvertiserLiveMapPage({super.key});

  @override
  ConsumerState<AdvertiserLiveMapPage> createState() =>
      _AdvertiserLiveMapPageState();
}

class _AdvertiserLiveMapPageState extends ConsumerState<AdvertiserLiveMapPage>
    with TickerProviderStateMixin {
  late final TabController _sheetTabs;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;

  bool _isMapReady = false;
  double _currentZoom = 12.0;
  final Map<String, PointAnnotation> _promoterMarkers = {};
  final Map<String, PolylineAnnotation> _routePolylines = {};

  @override
  void initState() {
    super.initState();
    _sheetTabs = TabController(length: 2, vsync: this);

    // Start polling when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(advertiserLiveProvider.notifier).startPolling();
    });
  }

  @override
  void dispose() {
    _sheetTabs.dispose();
    ref.read(advertiserLiveProvider.notifier).stopPolling();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create annotation managers
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    setState(() {
      _isMapReady = true;
    });

    // Initial update
    _updateMapAnnotations(ref.read(advertiserLiveProvider));
  }

  Future<void> _updateMapAnnotations(AdvertiserLiveState state) async {
    if (!_isMapReady ||
        _pointAnnotationManager == null ||
        _polylineAnnotationManager == null) {
      return;
    }

    // Clear existing annotations
    for (final marker in _promoterMarkers.values) {
      await _pointAnnotationManager!.delete(marker);
    }
    _promoterMarkers.clear();

    for (final polyline in _routePolylines.values) {
      await _polylineAnnotationManager!.delete(polyline);
    }
    _routePolylines.clear();

    // Add annotations for each campaign
    for (final campaign in state.filteredCampaigns) {
      // Add route polyline
      if (campaign.routeCoordinates.length >= 2) {
        final coordinates = campaign.routeCoordinates
            .map((p) => Position(p.lng, p.lat))
            .toList();

        final polylineOptions = PolylineAnnotationOptions(
          geometry: LineString(coordinates: coordinates),
          lineColor: _getCampaignColor(campaign.id).toARGB32(),
          lineWidth: 3.0,
          lineOpacity: 0.7,
        );

        final polyline =
            await _polylineAnnotationManager!.create(polylineOptions);
        _routePolylines[campaign.id] = polyline;
      }

      // Add promoter marker
      if (campaign.promoter != null &&
          campaign.promoter!.latitude != 0 &&
          campaign.promoter!.longitude != 0) {
        final point = Point(
          coordinates: Position(
            campaign.promoter!.longitude,
            campaign.promoter!.latitude,
          ),
        );

        final markerOptions = PointAnnotationOptions(
          geometry: point,
          iconSize: 1.2,
          iconColor:
              _getPromoterStatusColor(campaign.promoter!.status).toARGB32(),
        );

        final marker = await _pointAnnotationManager!.create(markerOptions);
        _promoterMarkers[campaign.id] = marker;
      }
    }

    // Center on selected campaign
    if (state.selectedCampaign?.promoter != null && state.isFollowing) {
      final promoter = state.selectedCampaign!.promoter!;
      if (promoter.latitude != 0 && promoter.longitude != 0) {
        await _mapboxMap?.setCamera(CameraOptions(
          center: Point(
            coordinates: Position(promoter.longitude, promoter.latitude),
          ),
        ));
      }
    }
  }

  Color _getCampaignColor(String campaignId) {
    // Generate consistent color based on campaign ID
    final colors = [
      AppColors.secondary,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    final index = campaignId.hashCode.abs() % colors.length;
    return colors[index];
  }

  Color _getPromoterStatusColor(PromoterExecutionStatus status) {
    switch (status) {
      case PromoterExecutionStatus.active:
        return Colors.green;
      case PromoterExecutionStatus.paused:
        return Colors.orange;
      case PromoterExecutionStatus.completed:
        return Colors.blue;
      case PromoterExecutionStatus.unknown:
        return Colors.grey;
    }
  }

  void _centerOnCampaign(LiveCampaign campaign) {
    ref.read(advertiserLiveProvider.notifier).selectCampaign(campaign.id);

    if (campaign.promoter != null &&
        campaign.promoter!.latitude != 0 &&
        campaign.promoter!.longitude != 0) {
      _mapboxMap?.setCamera(CameraOptions(
        center: Point(
          coordinates: Position(
            campaign.promoter!.longitude,
            campaign.promoter!.latitude,
          ),
        ),
        zoom: 15.0,
      ));
    } else if (campaign.routeCoordinates.isNotEmpty) {
      // Center on route if no promoter location
      final first = campaign.routeCoordinates.first;
      _mapboxMap?.setCamera(CameraOptions(
        center: Point(coordinates: Position(first.lng, first.lat)),
        zoom: 14.0,
      ));
    }
  }

  void _toggleFollowMode() {
    ref.read(advertiserLiveProvider.notifier).toggleFollowMode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(advertiserLiveProvider);

    // Update map when state changes
    ref.listen(advertiserLiveProvider, (previous, next) {
      if (previous?.campaigns != next.campaigns ||
          previous?.filter != next.filter) {
        _updateMapAnnotations(next);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // --- MAP LAYER ---
          _buildMap(state),

          // --- TOP BAR ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _LiveDot(label: l10n.liveLabel),
                        const Spacer(),
                        if (state.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        _ChipButton(
                          icon: Icons.layers_outlined,
                          label: l10n.layers,
                          onTap: () => showMapStylePicker(context),
                        ),
                        const SizedBox(width: 8),
                        if (state.lastRefresh != null)
                          _ChipButton(
                            icon: Icons.access_time,
                            label: l10n.now,
                            onTap: () {
                              ref
                                  .read(advertiserLiveProvider.notifier)
                                  .refresh();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- FLOATING CONTROLS ---
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                _RoundFab(
                  icon: Icons.my_location,
                  onPressed: () {
                    // Center on selected campaign or first campaign
                    final campaign = state.selectedCampaign ??
                        state.filteredCampaigns.firstOrNull;
                    if (campaign != null) {
                      _centerOnCampaign(campaign);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _RoundFab(
                  icon: state.isFollowing
                      ? Icons.center_focus_strong
                      : Icons.center_focus_weak,
                  onPressed: _toggleFollowMode,
                  isActive: state.isFollowing,
                ),
                const SizedBox(height: 8),
                _RoundFab(
                  icon: Icons.add,
                  onPressed: () {
                    _currentZoom = (_currentZoom + 1).clamp(1.0, 20.0);
                    _mapboxMap?.setCamera(CameraOptions(zoom: _currentZoom));
                  },
                ),
                const SizedBox(height: 8),
                _RoundFab(
                  icon: Icons.remove,
                  onPressed: () {
                    _currentZoom = (_currentZoom - 1).clamp(1.0, 20.0);
                    _mapboxMap?.setCamera(CameraOptions(zoom: _currentZoom));
                  },
                ),
              ],
            ),
          ),

          // --- DRAGGABLE SHEET (Promoters / Alerts) ---
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.18,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.25, 0.5, 0.9],
            builder: (context, controller) {
              return Material(
                color: theme.colorScheme.surface,
                elevation: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _Grabber(color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 4),
                    TabBar(
                      controller: _sheetTabs,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: l10n.activePromoters),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.alerts),
                              if (state.unreadAlertCount > 0) ...[
                                const SizedBox(width: 4),
                                _AlertBadge(count: state.unreadAlertCount),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _sheetTabs,
                        children: [
                          _PromotersList(
                            scrollController: controller,
                            state: state,
                            onSelectCampaign: _centerOnCampaign,
                          ),
                          _AlertsList(
                            scrollController: controller,
                            state: state,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap(AdvertiserLiveState state) {
    if (state.campaigns.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    final mapStyle = ref.watch(mapStyleProvider);

    // Listen for style changes and update the map
    ref.listen(mapStyleProvider, (previous, next) {
      if (_mapboxMap != null && previous != next) {
        _mapboxMap!.loadStyleURI(next.styleUri);
      }
    });

    return MapWidget(
      key: const ValueKey('advertiser-live-map'),
      onMapCreated: _onMapCreated,
      styleUri: mapStyle.styleUri,
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(-56.1645, -34.9011), // Montevideo default
        ),
        zoom: 12.0,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.podcasts_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveCampaigns,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.activePromotersDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------
// Sub-widgets
// --------------------------

class _PromotersList extends ConsumerWidget {
  const _PromotersList({
    required this.scrollController,
    required this.state,
    required this.onSelectCampaign,
  });

  final ScrollController scrollController;
  final AdvertiserLiveState state;
  final Function(LiveCampaign) onSelectCampaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        // Filters / chips row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: l10n.active,
              selected: state.filter == LiveCampaignFilter.active,
              onTap: () => ref
                  .read(advertiserLiveProvider.notifier)
                  .setFilter(LiveCampaignFilter.active),
            ),
            _FilterChip(
              label: l10n.pending,
              selected: state.filter == LiveCampaignFilter.pending,
              onTap: () => ref
                  .read(advertiserLiveProvider.notifier)
                  .setFilter(LiveCampaignFilter.pending),
            ),
            _FilterChip(
              label: l10n.noSignal,
              selected: state.filter == LiveCampaignFilter.noSignal,
              onTap: () => ref
                  .read(advertiserLiveProvider.notifier)
                  .setFilter(LiveCampaignFilter.noSignal),
            ),
            _FilterChip(
              label: l10n.all,
              selected: state.filter == LiveCampaignFilter.all,
              onTap: () => ref
                  .read(advertiserLiveProvider.notifier)
                  .setFilter(LiveCampaignFilter.all),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Campaign list
        if (state.filteredCampaigns.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.noCampaignsFound,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...state.filteredCampaigns.map((campaign) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PromoterItem(
                  campaign: campaign,
                  isSelected: state.selectedCampaignId == campaign.id,
                  onTap: () => onSelectCampaign(campaign),
                ),
              )),

        if (state.lastRefresh != null) ...[
          const SizedBox(height: 16),
          Text(
            '${l10n.lastUpdated} ${state.lastRefresh!.hour}:${state.lastRefresh!.minute.toString().padLeft(2, '0')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _PromoterItem extends StatelessWidget {
  const _PromoterItem({
    required this.campaign,
    required this.isSelected,
    required this.onTap,
  });

  final LiveCampaign campaign;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promoter = campaign.promoter;
    final isOnline =
        promoter != null && promoter.status == PromoterExecutionStatus.active;
    final isPaused = promoter?.status == PromoterExecutionStatus.paused;
    final hasNoSignal = promoter?.hasNoSignal ?? true;

    Color statusColor;
    if (hasNoSignal) {
      statusColor = theme.colorScheme.outline;
    } else if (isPaused) {
      statusColor = Colors.orange;
    } else if (isOnline) {
      statusColor = Colors.green;
    } else {
      statusColor = theme.colorScheme.outline;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promoter?.promoterName ?? 'Waiting for promoter',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    campaign.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (promoter != null && !hasNoSignal) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          promoter.formattedDistance,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          promoter.formattedElapsedTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.signal_cellular_alt,
              size: 18,
              color: promoter != null
                  ? _getSignalColor(promoter.signalStrength)
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Icon(Icons.podcasts, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Color _getSignalColor(int signal) {
    if (signal >= 3) return Colors.green;
    if (signal >= 2) return Colors.orange;
    if (signal >= 1) return Colors.red;
    return Colors.grey;
  }
}

class _AlertsList extends ConsumerWidget {
  const _AlertsList({
    required this.scrollController,
    required this.state,
  });

  final ScrollController scrollController;
  final AdvertiserLiveState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (state.alerts.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.alertsDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        if (state.unreadAlertCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextButton(
              onPressed: () {
                ref.read(advertiserLiveProvider.notifier).markAllAlertsAsRead();
              },
              child: Text('Mark all as read'),
            ),
          ),
        ...state.alerts.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AlertCard(
                alert: alert,
                onTap: () {
                  if (!alert.isRead) {
                    ref
                        .read(advertiserLiveProvider.notifier)
                        .markAlertAsRead(alert.id);
                  }
                },
              ),
            )),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onTap,
  });

  final CampaignAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (alert.type) {
      case CampaignAlertType.started:
        icon = Icons.play_circle_outline;
        color = Colors.green;
        break;
      case CampaignAlertType.paused:
        icon = Icons.pause_circle_outline;
        color = Colors.orange;
        break;
      case CampaignAlertType.resumed:
        icon = Icons.play_circle_outline;
        color = Colors.blue;
        break;
      case CampaignAlertType.completed:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case CampaignAlertType.noSignal:
        icon = Icons.signal_cellular_off;
        color = Colors.red;
        break;
      case CampaignAlertType.outOfZone:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: alert.isRead
              ? theme.colorScheme.surface
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.promoterName ?? alert.campaignTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: alert.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        alert.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!alert.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green.withValues(alpha: .4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _RoundFab extends StatelessWidget {
  const _RoundFab({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton.small(
      onPressed: onPressed,
      heroTag: null,
      backgroundColor: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        color:
            isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: .08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: .3)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? theme.colorScheme.primary : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
