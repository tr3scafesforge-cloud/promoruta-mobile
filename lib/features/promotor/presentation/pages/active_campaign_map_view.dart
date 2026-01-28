import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';

import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
import 'package:promoruta/features/promotor/route_execution/presentation/providers/campaign_execution_notifier.dart';

class ActiveCampaignMapView extends ConsumerStatefulWidget {
  final String campaignId;
  final String campaignName;
  final String location;
  final String? audioUrl;

  const ActiveCampaignMapView({
    super.key,
    required this.campaignId,
    required this.campaignName,
    required this.location,
    this.audioUrl,
  });

  @override
  ConsumerState<ActiveCampaignMapView> createState() =>
      _ActiveCampaignMapViewState();
}

class _ActiveCampaignMapViewState extends ConsumerState<ActiveCampaignMapView> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  PointAnnotation? _currentLocationMarker;
  PolylineAnnotation? _routePolyline;

  bool _isMapReady = false;
  bool _isAudioLoading = false;
  bool _audioLoadFailed = false;

  StreamSubscription<Duration>? _audioPositionSubscription;
  Duration _lastPersistedPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Load audio if available
    if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
      _loadAudio();
    }
  }

  @override
  void dispose() {
    // Persist final audio position before leaving
    _persistAudioPosition();
    _audioPositionSubscription?.cancel();
    // Stop audio when leaving the view
    final audioService = ref.read(campaignAudioServiceProvider);
    audioService.stop();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) return;

    setState(() {
      _isAudioLoading = true;
      _audioLoadFailed = false;
    });

    // Get persisted audio position
    final restoredPosition =
        await CampaignExecutionNotifier.getPersistedAudioPosition();

    final audioService = ref.read(campaignAudioServiceProvider);
    final success = await audioService.loadAudio(
      widget.audioUrl!,
      restorePosition: restoredPosition,
    );

    if (success) {
      // Set up periodic position persistence (every 5 seconds while playing)
      _audioPositionSubscription =
          audioService.positionStream.listen((position) {
        // Only persist if position changed by more than 5 seconds
        if ((position - _lastPersistedPosition).inSeconds.abs() >= 5) {
          _lastPersistedPosition = position;
          CampaignExecutionNotifier.persistAudioPosition(position);
        }
      });
    }

    if (mounted) {
      setState(() {
        _isAudioLoading = false;
        _audioLoadFailed = !success;
      });
    }
  }

  void _persistAudioPosition() {
    final audioService = ref.read(campaignAudioServiceProvider);
    final position = audioService.position;
    if (position > Duration.zero) {
      CampaignExecutionNotifier.persistAudioPosition(position);
    }
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

    // Get current position and center map
    final locationService = ref.read(campaignLocationServiceProvider);
    final currentPosition = await locationService.getCurrentPosition();
    if (currentPosition != null && _mapboxMap != null) {
      await _mapboxMap!.setCamera(CameraOptions(
        center: Point(
          coordinates: Position(
            currentPosition.longitude,
            currentPosition.latitude,
          ),
        ),
        zoom: 16.0,
      ));
    }
  }

  void _updateLocationMarker(ExecutionGpsPoint? position) async {
    if (!_isMapReady || _pointAnnotationManager == null || position == null) {
      return;
    }

    final point = Point(
      coordinates: Position(position.longitude, position.latitude),
    );

    // Remove existing marker
    if (_currentLocationMarker != null) {
      await _pointAnnotationManager!.delete(_currentLocationMarker!);
    }

    // Create new marker
    final options = PointAnnotationOptions(
      geometry: point,
      iconSize: 1.5,
      iconColor: AppColors.secondary.toARGB32(),
    );

    _currentLocationMarker = await _pointAnnotationManager!.create(options);

    // Center map on current location
    await _mapboxMap?.setCamera(CameraOptions(
      center: point,
    ));
  }

  void _updateRoutePolyline(List<ExecutionGpsPoint> points) async {
    if (!_isMapReady ||
        _polylineAnnotationManager == null ||
        points.length < 2) {
      return;
    }

    final coordinates =
        points.map((p) => Position(p.longitude, p.latitude)).toList();

    // Remove existing polyline
    if (_routePolyline != null) {
      await _polylineAnnotationManager!.delete(_routePolyline!);
    }

    // Create new polyline
    final options = PolylineAnnotationOptions(
      geometry: LineString(coordinates: coordinates),
      lineColor: AppColors.secondary.toARGB32(),
      lineWidth: 4.0,
    );

    _routePolyline = await _polylineAnnotationManager!.create(options);
  }

  Future<void> _startExecution() async {
    final confirmed = await _showStartConfirmationDialog();
    if (!confirmed) return;

    final success =
        await ref.read(campaignExecutionProvider.notifier).startExecution(
              campaignId: widget.campaignId,
              campaignName: widget.campaignName,
            );

    if (!success && mounted) {
      final state = ref.read(campaignExecutionProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Failed to start tracking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pauseExecution() {
    ref.read(campaignExecutionProvider.notifier).pauseExecution();
  }

  void _resumeExecution() {
    ref.read(campaignExecutionProvider.notifier).resumeExecution();
  }

  Future<void> _completeExecution() async {
    final confirmed = await _showCompleteConfirmationDialog();
    if (!confirmed) return;

    final summary =
        await ref.read(campaignExecutionProvider.notifier).completeExecution();

    if (mounted) {
      await _showCompletionSummaryDialog(summary);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _centerOnLocation() async {
    final state = ref.read(campaignExecutionProvider);
    if (state.currentPosition != null && _mapboxMap != null) {
      await _mapboxMap!.setCamera(CameraOptions(
        center: Point(
          coordinates: Position(
            state.currentPosition!.longitude,
            state.currentPosition!.latitude,
          ),
        ),
        zoom: 16.0,
      ));
    }
  }

  Future<bool> _showStartConfirmationDialog() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.startCampaign),
            content: Text(l10n.startCampaignConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: Text(l10n.start),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showCompleteConfirmationDialog() async {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(campaignExecutionProvider);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.completeCampaign),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.completeCampaignConfirmation),
                const SizedBox(height: 16),
                Text('${l10n.elapsedTime}: ${state.formattedElapsedTime}'),
                Text('${l10n.distanceTraveled}: ${state.formattedDistance}'),
                Text('${l10n.gpsPointsCollected}: ${state.allPoints.length}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                ),
                child: Text(l10n.complete),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showCompletionSummaryDialog(
      CampaignExecutionSummary summary) async {
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.green),
            const SizedBox(width: 8),
            Text(l10n.campaignCompleted),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.campaignName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
                Icons.timer, l10n.duration, summary.formattedDuration),
            _buildSummaryRow(
                Icons.straighten, l10n.distance, summary.formattedDistance),
            _buildSummaryRow(
                Icons.location_on, l10n.gpsPoints, '${summary.totalPoints}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final executionState = ref.watch(campaignExecutionProvider);

    // Update map when location changes
    ref.listen(campaignExecutionProvider, (previous, next) {
      if (next.currentPosition != previous?.currentPosition) {
        _updateLocationMarker(next.currentPosition);
      }
      if (next.allPoints.length != (previous?.allPoints.length ?? 0)) {
        _updateRoutePolyline(next.allPoints);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(l10n, theme, executionState),

            // Map Area
            Expanded(
              child: Stack(
                children: [
                  // Mapbox Map
                  MapWidget(
                    key: const ValueKey('mapbox-map'),
                    onMapCreated: _onMapCreated,
                    styleUri: MapboxStyles.MAPBOX_STREETS,
                    cameraOptions: CameraOptions(
                      center: Point(
                        coordinates:
                            Position(-56.1645, -34.9011), // Montevideo default
                      ),
                      zoom: 14.0,
                    ),
                  ),

                  // Center on location button
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      onPressed: _centerOnLocation,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),

                  // Loading indicator if map not ready
                  if (!_isMapReady)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),

            // Bottom Controls
            _buildBottomControls(l10n, theme, executionState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      AppLocalizations l10n, ThemeData theme, CampaignExecutionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grayLightStroke,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.campaignName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusBadge(state.status, l10n),
                    if (state.hasActiveExecution) ...[
                      const SizedBox(width: 8),
                      Text(
                        state.formattedElapsedTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!state.hasActiveExecution)
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(l10n.close),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
      CampaignExecutionStatus status, AppLocalizations l10n) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case CampaignExecutionStatus.idle:
        bgColor = AppColors.grayLightStroke;
        textColor = AppColors.textSecondary;
        text = l10n.notStarted;
        break;
      case CampaignExecutionStatus.starting:
        bgColor = AppColors.secondary.withValues(alpha: 0.1);
        textColor = AppColors.secondary;
        text = l10n.starting;
        break;
      case CampaignExecutionStatus.active:
        bgColor = AppColors.green.withValues(alpha: 0.1);
        textColor = AppColors.green;
        text = l10n.tracking;
        break;
      case CampaignExecutionStatus.paused:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        text = l10n.paused;
        break;
      case CampaignExecutionStatus.completing:
        bgColor = AppColors.secondary.withValues(alpha: 0.1);
        textColor = AppColors.secondary;
        text = l10n.completing;
        break;
      case CampaignExecutionStatus.completed:
        bgColor = AppColors.green.withValues(alpha: 0.1);
        textColor = AppColors.green;
        text = l10n.completedStatus;
        break;
      case CampaignExecutionStatus.error:
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        text = l10n.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomControls(
      AppLocalizations l10n, ThemeData theme, CampaignExecutionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Audio Player (when audio is available)
          if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) ...[
            _buildAudioPlayer(l10n),
            const SizedBox(height: 12),
          ],

          // Stats Row (when tracking)
          if (state.hasActiveExecution) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    label: l10n.elapsedTime,
                    value: state.formattedElapsedTime,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.straighten,
                    label: l10n.distance,
                    value: state.formattedDistance,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Action Buttons
          _buildActionButtons(l10n, state),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(AppLocalizations l10n) {
    final audioService = ref.watch(campaignAudioServiceProvider);

    if (_isAudioLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grayLightStroke),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.audio,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_audioLoadFailed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: _loadAudio,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;
        final processingState =
            playerState?.processingState ?? ProcessingState.idle;
        final isLoading = processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLightStroke),
          ),
          child: Column(
            children: [
              // Audio Controls Row
              Row(
                children: [
                  // Play/Pause Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                      onPressed: isLoading
                          ? null
                          : () => audioService.togglePlayPause(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Progress and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Slider
                        StreamBuilder<Duration>(
                          stream: audioService.positionStream,
                          builder: (context, posSnapshot) {
                            final position = posSnapshot.data ?? Duration.zero;
                            final duration =
                                audioService.duration ?? Duration.zero;
                            final progress = duration.inMilliseconds > 0
                                ? position.inMilliseconds /
                                    duration.inMilliseconds
                                : 0.0;

                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                    activeTrackColor: AppColors.secondary,
                                    inactiveTrackColor:
                                        AppColors.grayLightStroke,
                                    thumbColor: AppColors.secondary,
                                  ),
                                  child: Slider(
                                    value: progress.clamp(0.0, 1.0),
                                    onChanged: (value) {
                                      if (duration.inMilliseconds > 0) {
                                        final newPosition = Duration(
                                          milliseconds:
                                              (value * duration.inMilliseconds)
                                                  .round(),
                                        );
                                        audioService.seek(newPosition);
                                      }
                                    },
                                  ),
                                ),
                                // Time Display
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(position),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(duration),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      AppLocalizations l10n, CampaignExecutionState state) {
    switch (state.status) {
      case CampaignExecutionStatus.idle:
      case CampaignExecutionStatus.error:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startExecution,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.startTracking),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );

      case CampaignExecutionStatus.starting:
      case CampaignExecutionStatus.completing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );

      case CampaignExecutionStatus.active:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pauseExecution,
                icon: const Icon(Icons.pause),
                label: Text(l10n.pause),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completeExecution,
                icon: const Icon(Icons.check),
                label: Text(l10n.complete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );

      case CampaignExecutionStatus.paused:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _resumeExecution,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.resume),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completeExecution,
                icon: const Icon(Icons.check),
                label: Text(l10n.complete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );

      case CampaignExecutionStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.done),
            label: Text(l10n.done),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
    }
  }
}
