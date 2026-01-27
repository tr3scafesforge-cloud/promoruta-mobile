import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/models/live_campaign_models.dart';

/// Remote data source for advertiser live campaign data
abstract class AdvertiserLiveRemoteDataSource {
  /// Fetch live campaigns from the API
  Future<List<LiveCampaign>> getLiveCampaigns();

  /// Fetch a specific live campaign
  Future<LiveCampaign?> getLiveCampaign(String campaignId);

  /// Fetch alerts for the advertiser
  Future<List<CampaignAlert>> getAlerts({int? limit});

  /// Mark an alert as read
  Future<void> markAlertAsRead(String alertId);

  /// Mark all alerts as read
  Future<void> markAllAlertsAsRead();
}

/// Implementation of [AdvertiserLiveRemoteDataSource]
class AdvertiserLiveRemoteDataSourceImpl
    implements AdvertiserLiveRemoteDataSource {
  final Dio dio;

  AdvertiserLiveRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LiveCampaign>> getLiveCampaigns() async {
    try {
      AppLogger.campaign.i('Fetching live campaigns for advertiser');

      // Try the dedicated live endpoint first
      try {
        final response = await dio.get(
          '/advertiser/live-campaigns',
          options: Options(
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final campaigns = data['campaigns'] as List? ?? data as List? ?? [];
          AppLogger.campaign.i('Fetched ${campaigns.length} live campaigns');

          return campaigns
              .map(
                  (json) => LiveCampaign.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } on DioException catch (e) {
        // If the dedicated endpoint doesn't exist (404), fall back to regular campaigns
        if (e.response?.statusCode == 404) {
          AppLogger.campaign.w(
            'Live campaigns endpoint not found, falling back to active campaigns',
          );
          return _fetchActiveCampaignsFallback();
        }
        rethrow;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.campaign.e('Failed to fetch live campaigns: ${e.message}');
      throw Exception('Failed to fetch live campaigns: ${e.message}');
    } catch (e) {
      AppLogger.campaign.e('Unexpected error fetching live campaigns: $e');
      throw Exception('Failed to fetch live campaigns: $e');
    }
  }

  /// Fallback: fetch active campaigns using the regular campaigns endpoint
  Future<List<LiveCampaign>> _fetchActiveCampaignsFallback() async {
    try {
      final response = await dio.get(
        '/campaigns',
        queryParameters: {'status': 'active'},
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final campaigns = data is List ? data : (data['data'] as List? ?? []);

        return campaigns.map((json) {
          final campaignJson = json as Map<String, dynamic>;
          // Transform regular campaign to LiveCampaign format
          return LiveCampaign(
            id: campaignJson['id'] as String,
            title: campaignJson['title'] as String,
            zone: campaignJson['zone'] as String? ?? '',
            promoter: _extractPromoterFromCampaign(campaignJson),
            routeCoordinates: _extractRouteCoordinates(campaignJson),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      AppLogger.campaign.e('Fallback campaign fetch failed: $e');
      return [];
    }
  }

  LivePromoterLocation? _extractPromoterFromCampaign(
      Map<String, dynamic> campaign) {
    final acceptedBy = campaign['accepted_by'] as Map<String, dynamic>?;
    if (acceptedBy == null) return null;

    // This is a simplified version - the full version would include
    // real-time location data from GPS tracks
    return LivePromoterLocation(
      campaignId: campaign['id'] as String,
      promoterId: acceptedBy['id'] as String? ?? '',
      promoterName: acceptedBy['name'] as String? ?? 'Unknown',
      latitude: 0.0,
      longitude: 0.0,
      lastUpdate: DateTime.now(),
      distanceTraveled: 0.0,
      elapsedTime: Duration.zero,
      status: PromoterExecutionStatus.unknown,
      signalStrength: 0,
    );
  }

  List<RoutePoint> _extractRouteCoordinates(Map<String, dynamic> campaign) {
    final coords = campaign['route_coordinates'] as List?;
    if (coords == null) return [];

    return coords
        .map((c) => RoutePoint.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LiveCampaign?> getLiveCampaign(String campaignId) async {
    try {
      AppLogger.campaign.i('Fetching live campaign: $campaignId');

      // Try dedicated endpoint first
      try {
        final response = await dio.get(
          '/advertiser/live-campaigns/$campaignId',
          options: Options(
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          return LiveCampaign.fromJson(response.data as Map<String, dynamic>);
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // Fallback to regular campaign endpoint
          return _fetchCampaignFallback(campaignId);
        }
        rethrow;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.campaign.e('Failed to fetch live campaign: ${e.message}');
      throw Exception('Failed to fetch live campaign: ${e.message}');
    }
  }

  Future<LiveCampaign?> _fetchCampaignFallback(String campaignId) async {
    try {
      final response = await dio.get(
        '/campaigns/$campaignId',
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return LiveCampaign(
          id: json['id'] as String,
          title: json['title'] as String,
          zone: json['zone'] as String? ?? '',
          promoter: _extractPromoterFromCampaign(json),
          routeCoordinates: _extractRouteCoordinates(json),
        );
      }
      return null;
    } catch (e) {
      AppLogger.campaign.w('Campaign fallback fetch failed: $e');
      return null;
    }
  }

  @override
  Future<List<CampaignAlert>> getAlerts({int? limit}) async {
    try {
      AppLogger.campaign.i('Fetching campaign alerts');

      try {
        final queryParams = <String, dynamic>{};
        if (limit != null) {
          queryParams['limit'] = limit;
        }

        final response = await dio.get(
          '/advertiser/alerts',
          queryParameters: queryParams.isEmpty ? null : queryParams,
          options: Options(
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final alerts = data['alerts'] as List? ?? data as List? ?? [];

          return alerts.map((json) {
            final alertJson = json as Map<String, dynamic>;
            return CampaignAlert(
              id: alertJson['id'] as String,
              campaignId: alertJson['campaign_id'] as String,
              campaignTitle: alertJson['campaign_title'] as String? ?? '',
              promoterName: alertJson['promoter_name'] as String?,
              type: _parseAlertType(alertJson['type'] as String?),
              message: alertJson['message'] as String? ?? '',
              createdAt: alertJson['created_at'] != null
                  ? DateTime.parse(alertJson['created_at'] as String)
                  : DateTime.now(),
              isRead: alertJson['is_read'] as bool? ?? false,
            );
          }).toList();
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // Alerts endpoint doesn't exist yet - return empty list
          AppLogger.campaign
              .w('Alerts endpoint not found, returning empty list');
          return [];
        }
        rethrow;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.campaign.e('Failed to fetch alerts: ${e.message}');
      // Don't throw for alerts - return empty list as fallback
      return [];
    } catch (e) {
      AppLogger.campaign.e('Unexpected error fetching alerts: $e');
      return [];
    }
  }

  CampaignAlertType _parseAlertType(String? type) {
    switch (type?.toLowerCase()) {
      case 'started':
        return CampaignAlertType.started;
      case 'paused':
        return CampaignAlertType.paused;
      case 'resumed':
        return CampaignAlertType.resumed;
      case 'completed':
        return CampaignAlertType.completed;
      case 'no_signal':
        return CampaignAlertType.noSignal;
      case 'out_of_zone':
        return CampaignAlertType.outOfZone;
      default:
        return CampaignAlertType.started;
    }
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await dio.patch(
        '/advertiser/alerts/$alertId',
        data: {'is_read': true},
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      // If endpoint doesn't exist, silently ignore
      if (e.response?.statusCode == 404) {
        AppLogger.campaign.w('Mark alert read endpoint not found');
        return;
      }
      AppLogger.campaign.e('Failed to mark alert as read: ${e.message}');
    }
  }

  @override
  Future<void> markAllAlertsAsRead() async {
    try {
      await dio.post(
        '/advertiser/alerts/mark-all-read',
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      // If endpoint doesn't exist, silently ignore
      if (e.response?.statusCode == 404) {
        AppLogger.campaign.w('Mark all alerts read endpoint not found');
        return;
      }
      AppLogger.campaign.e('Failed to mark all alerts as read: ${e.message}');
    }
  }
}
