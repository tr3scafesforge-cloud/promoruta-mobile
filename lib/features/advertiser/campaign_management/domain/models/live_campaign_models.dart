import 'package:equatable/equatable.dart';
import 'package:promoruta/shared/constants/time_thresholds.dart';

/// Status of promoter's campaign execution (from advertiser's perspective)
enum PromoterExecutionStatus {
  /// Promoter is actively executing the campaign
  active,

  /// Promoter has paused the execution
  paused,

  /// Campaign execution completed
  completed,

  /// No data received from promoter
  unknown,
}

/// Real-time location and execution data for a promoter
class LivePromoterLocation extends Equatable {
  /// Campaign ID being executed
  final String campaignId;

  /// Promoter's user ID
  final String promoterId;

  /// Promoter's display name
  final String promoterName;

  /// Current latitude
  final double latitude;

  /// Current longitude
  final double longitude;

  /// When this location was last updated
  final DateTime lastUpdate;

  /// Distance traveled in kilometers
  final double distanceTraveled;

  /// Time elapsed since execution started
  final Duration elapsedTime;

  /// Current execution status
  final PromoterExecutionStatus status;

  /// Signal strength indicator (0-4, 0 = no signal)
  final int signalStrength;

  /// When execution started
  final DateTime? startedAt;

  const LivePromoterLocation({
    required this.campaignId,
    required this.promoterId,
    required this.promoterName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdate,
    required this.distanceTraveled,
    required this.elapsedTime,
    required this.status,
    required this.signalStrength,
    this.startedAt,
  });

  /// Whether the location data is considered stale
  bool get isStale {
    final now = DateTime.now();
    return now.difference(lastUpdate) >= TimeThresholds.staleDataThreshold;
  }

  /// Whether there's no signal (no update within threshold)
  bool get hasNoSignal {
    final now = DateTime.now();
    return now.difference(lastUpdate) >= TimeThresholds.noSignalThreshold;
  }

  /// Format elapsed time as HH:MM
  String get formattedElapsedTime {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Format distance as string
  String get formattedDistance {
    if (distanceTraveled < 1) {
      return '${(distanceTraveled * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceTraveled.toStringAsFixed(2)} km';
  }

  factory LivePromoterLocation.fromJson(Map<String, dynamic> json) {
    // Support both backend flat format and nested format for backwards compatibility
    final location = json['location'] as Map<String, dynamic>?;
    final execution = json['execution'] as Map<String, dynamic>?;

    // Determine if using flat format (from backend) or nested format
    final isFlat =
        json.containsKey('latitude') || json.containsKey('promoter_id');

    if (isFlat) {
      // Backend flat format
      final lastUpdateStr = json['last_update'] as String?;
      final lastUpdate = lastUpdateStr != null
          ? DateTime.parse(lastUpdateStr)
          : DateTime.now();

      return LivePromoterLocation(
        campaignId: json['campaign_id'] as String? ?? '',
        promoterId: json['promoter_id'] as String? ?? '',
        promoterName: json['promoter_name'] as String? ?? 'Unknown',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        lastUpdate: lastUpdate,
        distanceTraveled:
            (json['distance_traveled'] as num?)?.toDouble() ?? 0.0,
        elapsedTime: Duration(
          seconds: (json['elapsed_seconds'] as num?)?.toInt() ?? 0,
        ),
        status: _parseStatus(json['status'] as String?),
        signalStrength: (json['signal_strength'] as num?)?.toInt() ?? 0,
        startedAt: null,
      );
    }

    // Legacy nested format
    return LivePromoterLocation(
      campaignId: json['campaign_id'] as String? ?? '',
      promoterId: json['id'] as String? ?? '',
      promoterName: json['name'] as String? ?? 'Unknown',
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0.0,
      lastUpdate: location?['updated_at'] != null
          ? DateTime.parse(location!['updated_at'] as String)
          : DateTime.now(),
      distanceTraveled: (execution?['distance_km'] as num?)?.toDouble() ?? 0.0,
      elapsedTime: Duration(
        minutes: (execution?['elapsed_minutes'] as num?)?.toInt() ?? 0,
      ),
      status: _parseStatus(execution?['status'] as String?),
      signalStrength: _calculateSignalStrength(
        location?['updated_at'] != null
            ? DateTime.parse(location!['updated_at'] as String)
            : null,
      ),
      startedAt: execution?['started_at'] != null
          ? DateTime.parse(execution!['started_at'] as String)
          : null,
    );
  }

  static PromoterExecutionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return PromoterExecutionStatus.active;
      case 'paused':
        return PromoterExecutionStatus.paused;
      case 'completed':
        return PromoterExecutionStatus.completed;
      default:
        return PromoterExecutionStatus.unknown;
    }
  }

  static int _calculateSignalStrength(DateTime? lastUpdate) {
    if (lastUpdate == null) return 0;
    final now = DateTime.now();
    final minutesAgo = now.difference(lastUpdate).inMinutes;

    if (minutesAgo >= TimeThresholds.signalLevel1MaxMinutes) return 0;
    if (minutesAgo >= TimeThresholds.signalLevel2MaxMinutes) return 1;
    if (minutesAgo >= TimeThresholds.signalLevel3MaxMinutes) return 2;
    if (minutesAgo >= TimeThresholds.signalLevel4MaxMinutes) return 3;
    return 4;
  }

  LivePromoterLocation copyWith({
    String? campaignId,
    String? promoterId,
    String? promoterName,
    double? latitude,
    double? longitude,
    DateTime? lastUpdate,
    double? distanceTraveled,
    Duration? elapsedTime,
    PromoterExecutionStatus? status,
    int? signalStrength,
    DateTime? startedAt,
  }) {
    return LivePromoterLocation(
      campaignId: campaignId ?? this.campaignId,
      promoterId: promoterId ?? this.promoterId,
      promoterName: promoterName ?? this.promoterName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  List<Object?> get props => [
        campaignId,
        promoterId,
        promoterName,
        latitude,
        longitude,
        lastUpdate,
        distanceTraveled,
        elapsedTime,
        status,
        signalStrength,
        startedAt,
      ];
}

/// A live campaign with promoter execution data
class LiveCampaign extends Equatable {
  /// Campaign ID
  final String id;

  /// Campaign title
  final String title;

  /// Campaign zone/location name
  final String zone;

  /// Promoter's live location and execution data
  final LivePromoterLocation? promoter;

  /// Planned route coordinates
  final List<RoutePoint> routeCoordinates;

  /// Coverage zone polygon (if any)
  final List<RoutePoint>? coverageZone;

  const LiveCampaign({
    required this.id,
    required this.title,
    required this.zone,
    this.promoter,
    this.routeCoordinates = const [],
    this.coverageZone,
  });

  /// Whether the campaign has an active promoter
  bool get hasActivePromoter =>
      promoter != null && promoter!.status == PromoterExecutionStatus.active;

  /// Whether the promoter has no signal
  bool get promoterHasNoSignal => promoter?.hasNoSignal ?? true;

  factory LiveCampaign.fromJson(Map<String, dynamic> json) {
    final promoterJson = json['promoter'] as Map<String, dynamic>?;
    final routeCoords = json['route_coordinates'] as List? ?? [];
    final coverageCoords = json['coverage_zone'] as List?;

    return LiveCampaign(
      id: json['id'] as String,
      title: json['title'] as String,
      zone: json['zone'] as String? ?? '',
      promoter: promoterJson != null
          ? LivePromoterLocation.fromJson({
              ...promoterJson,
              'campaign_id': json['id'],
            })
          : null,
      routeCoordinates: routeCoords
          .map((c) => RoutePoint.fromJson(c as Map<String, dynamic>))
          .toList(),
      coverageZone: coverageCoords
          ?.map((c) => RoutePoint.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  LiveCampaign copyWith({
    String? id,
    String? title,
    String? zone,
    LivePromoterLocation? promoter,
    List<RoutePoint>? routeCoordinates,
    List<RoutePoint>? coverageZone,
  }) {
    return LiveCampaign(
      id: id ?? this.id,
      title: title ?? this.title,
      zone: zone ?? this.zone,
      promoter: promoter ?? this.promoter,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      coverageZone: coverageZone ?? this.coverageZone,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        zone,
        promoter,
        routeCoordinates,
        coverageZone,
      ];
}

/// A point on a route
class RoutePoint extends Equatable {
  final double lat;
  final double lng;

  const RoutePoint({
    required this.lat,
    required this.lng,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  List<Object?> get props => [lat, lng];
}

/// Type of campaign alert
enum CampaignAlertType {
  /// Campaign execution started
  started,

  /// Campaign execution paused
  paused,

  /// Campaign execution resumed
  resumed,

  /// Campaign execution completed
  completed,

  /// No signal from promoter
  noSignal,

  /// Promoter left coverage zone
  outOfZone,
}

/// An alert about campaign execution
class CampaignAlert extends Equatable {
  /// Unique alert ID
  final String id;

  /// Campaign ID this alert is for
  final String campaignId;

  /// Campaign title
  final String campaignTitle;

  /// Promoter name (if applicable)
  final String? promoterName;

  /// Type of alert
  final CampaignAlertType type;

  /// Alert message
  final String message;

  /// When the alert was created
  final DateTime createdAt;

  /// Whether the alert has been read
  final bool isRead;

  const CampaignAlert({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    this.promoterName,
    required this.type,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  /// Time ago string for display
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  CampaignAlert copyWith({
    String? id,
    String? campaignId,
    String? campaignTitle,
    String? promoterName,
    CampaignAlertType? type,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CampaignAlert(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      promoterName: promoterName ?? this.promoterName,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        campaignId,
        campaignTitle,
        promoterName,
        type,
        message,
        createdAt,
        isRead,
      ];
}

/// Filter options for the live campaign list
enum LiveCampaignFilter {
  /// Show all campaigns
  all,

  /// Show only active (executing) campaigns
  active,

  /// Show campaigns waiting for promoter
  pending,

  /// Show campaigns with no signal from promoter
  noSignal,
}

/// State of the advertiser live view
class AdvertiserLiveState extends Equatable {
  /// All live campaigns
  final List<LiveCampaign> campaigns;

  /// Currently selected campaign ID (for map focus)
  final String? selectedCampaignId;

  /// Current filter
  final LiveCampaignFilter filter;

  /// Whether follow mode is enabled (auto-center on selected promoter)
  final bool isFollowing;

  /// Campaign alerts
  final List<CampaignAlert> alerts;

  /// Number of unread alerts
  final int unreadAlertCount;

  /// Whether data is being loaded
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Last time data was refreshed
  final DateTime? lastRefresh;

  const AdvertiserLiveState({
    this.campaigns = const [],
    this.selectedCampaignId,
    this.filter = LiveCampaignFilter.all,
    this.isFollowing = false,
    this.alerts = const [],
    this.unreadAlertCount = 0,
    this.isLoading = false,
    this.error,
    this.lastRefresh,
  });

  /// Get filtered campaigns based on current filter
  List<LiveCampaign> get filteredCampaigns {
    switch (filter) {
      case LiveCampaignFilter.all:
        return campaigns;
      case LiveCampaignFilter.active:
        return campaigns
            .where((c) =>
                c.promoter?.status == PromoterExecutionStatus.active ||
                c.promoter?.status == PromoterExecutionStatus.paused)
            .toList();
      case LiveCampaignFilter.pending:
        return campaigns.where((c) => c.promoter == null).toList();
      case LiveCampaignFilter.noSignal:
        return campaigns.where((c) => c.promoterHasNoSignal).toList();
    }
  }

  /// Get the currently selected campaign
  LiveCampaign? get selectedCampaign {
    if (selectedCampaignId == null) return null;
    return campaigns.where((c) => c.id == selectedCampaignId).firstOrNull;
  }

  /// Whether there are any active campaigns
  bool get hasActiveCampaigns => campaigns.any((c) => c.hasActivePromoter);

  AdvertiserLiveState copyWith({
    List<LiveCampaign>? campaigns,
    String? selectedCampaignId,
    LiveCampaignFilter? filter,
    bool? isFollowing,
    List<CampaignAlert>? alerts,
    int? unreadAlertCount,
    bool? isLoading,
    String? error,
    DateTime? lastRefresh,
    bool clearSelectedCampaign = false,
    bool clearError = false,
  }) {
    return AdvertiserLiveState(
      campaigns: campaigns ?? this.campaigns,
      selectedCampaignId: clearSelectedCampaign
          ? null
          : (selectedCampaignId ?? this.selectedCampaignId),
      filter: filter ?? this.filter,
      isFollowing: isFollowing ?? this.isFollowing,
      alerts: alerts ?? this.alerts,
      unreadAlertCount: unreadAlertCount ?? this.unreadAlertCount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }

  @override
  List<Object?> get props => [
        campaigns,
        selectedCampaignId,
        filter,
        isFollowing,
        alerts,
        unreadAlertCount,
        isLoading,
        error,
        lastRefresh,
      ];
}
