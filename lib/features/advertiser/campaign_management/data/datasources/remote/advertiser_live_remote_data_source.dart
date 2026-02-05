import 'package:dio/dio.dart';
import 'package:promoruta/core/models/app_error.dart';
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
          final campaigns = _extractListFromResponse(data, 'campaigns');
          AppLogger.campaign.i('Fetched ${campaigns.length} live campaigns');

          return _parseListSafely(
            campaigns,
            (json) => LiveCampaign.fromJson(_asMapOrThrow(json, 'campaign')),
            'LiveCampaign',
          );
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
    } on ParsingError catch (e) {
      AppLogger.campaign.e('Parsing error in live campaigns: ${e.message}');
      throw Exception('Failed to parse live campaigns: ${e.message}');
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
        final campaigns = _extractListFromResponse(data, 'data');

        return _parseListSafely(
          campaigns,
          (json) {
            final campaignJson = _asMapOrThrow(json, 'campaign');
            // Transform regular campaign to LiveCampaign format
            return LiveCampaign(
              id: _getString(campaignJson, 'id'),
              title: _getString(campaignJson, 'title'),
              zone: _getStringOrDefault(campaignJson, 'zone', ''),
              promoter: _extractPromoterFromCampaign(campaignJson),
              routeCoordinates: _extractRouteCoordinates(campaignJson),
            );
          },
          'Campaign',
        );
      }

      return [];
    } catch (e) {
      AppLogger.campaign.e('Fallback campaign fetch failed: $e');
      return [];
    }
  }

  LivePromoterLocation? _extractPromoterFromCampaign(
      Map<String, dynamic> campaign) {
    final acceptedByRaw = campaign['accepted_by'];
    if (acceptedByRaw == null) return null;
    if (acceptedByRaw is! Map<String, dynamic>) return null;

    final acceptedBy = acceptedByRaw;

    // This is a simplified version - the full version would include
    // real-time location data from GPS tracks
    return LivePromoterLocation(
      campaignId: _getStringOrDefault(campaign, 'id', ''),
      promoterId: _getStringOrDefault(acceptedBy, 'id', ''),
      promoterName: _getStringOrDefault(acceptedBy, 'name', 'Unknown'),
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
    final coords = campaign['route_coordinates'];
    if (coords == null) return [];
    if (coords is! List) return [];

    return _parseListSafely(
      coords,
      (c) => RoutePoint.fromJson(_asMapOrThrow(c, 'route_point')),
      'RoutePoint',
    );
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
          final data = response.data;
          return LiveCampaign.fromJson(
              _asMapOrThrow(data, 'live_campaign_response'));
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
    } on ParsingError catch (e) {
      AppLogger.campaign.e('Parsing error in live campaign: ${e.message}');
      throw Exception('Failed to parse live campaign: ${e.message}');
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
        final json = _asMapOrThrow(response.data, 'campaign_response');
        return LiveCampaign(
          id: _getString(json, 'id'),
          title: _getString(json, 'title'),
          zone: _getStringOrDefault(json, 'zone', ''),
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
          final alerts = _extractListFromResponse(data, 'alerts');

          return _parseListSafely(
            alerts,
            (json) => _parseAlert(_asMapOrThrow(json, 'alert')),
            'CampaignAlert',
          );
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

  CampaignAlert _parseAlert(Map<String, dynamic> alertJson) {
    return CampaignAlert(
      id: _getString(alertJson, 'id'),
      campaignId: _getString(alertJson, 'campaign_id'),
      campaignTitle: _getStringOrDefault(alertJson, 'campaign_title', ''),
      promoterName: _getStringOrNull(alertJson, 'promoter_name'),
      type: _parseAlertType(_getStringOrNull(alertJson, 'type')),
      message: _getStringOrDefault(alertJson, 'message', ''),
      createdAt: _getDateTimeOrDefault(alertJson, 'created_at', DateTime.now()),
      isRead: _getBoolOrDefault(alertJson, 'is_read', false),
    );
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

  // ============ Safe JSON parsing helpers ============

  /// Extracts a List from response data, trying the key first, then the data itself.
  List<dynamic> _extractListFromResponse(dynamic data, String key) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value is List) return value;
    }
    return [];
  }

  /// Safely parses a list of items, logging errors for individual items.
  List<T> _parseListSafely<T>(
    List<dynamic> items,
    T Function(dynamic) parser,
    String itemType,
  ) {
    final results = <T>[];
    for (var i = 0; i < items.length; i++) {
      try {
        results.add(parser(items[i]));
      } catch (e) {
        AppLogger.campaign.w('Failed to parse $itemType at index $i: $e');
        // Continue parsing other items
      }
    }
    return results;
  }

  /// Validates and casts to [Map], throwing [ParsingError] if invalid.
  Map<String, dynamic> _asMapOrThrow(dynamic value, String context) {
    if (value is Map<String, dynamic>) return value;
    throw ParsingError(
      message: 'Expected Map<String, dynamic> for $context, got ${value.runtimeType}',
      field: context,
    );
  }

  /// Gets a required String field, throwing ParsingError if missing or wrong type.
  String _getString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) return value;
    if (value == null) {
      throw ParsingError.missingField(key);
    }
    throw ParsingError.typeMismatch(
      field: key,
      expectedType: 'String',
      actualType: '${value.runtimeType}',
    );
  }

  /// Gets an optional String field, returning null if missing or wrong type.
  String? _getStringOrNull(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) return value;
    return null;
  }

  /// Gets a String field with a default value if missing or wrong type.
  String _getStringOrDefault(Map<String, dynamic> map, String key, String defaultValue) {
    final value = map[key];
    if (value is String) return value;
    return defaultValue;
  }

  /// Gets a bool field with a default value if missing or wrong type.
  bool _getBoolOrDefault(Map<String, dynamic> map, String key, bool defaultValue) {
    final value = map[key];
    if (value is bool) return value;
    return defaultValue;
  }

  /// Gets a DateTime field with a default value if missing, invalid, or wrong type.
  DateTime _getDateTimeOrDefault(
    Map<String, dynamic> map,
    String key,
    DateTime defaultValue,
  ) {
    final value = map[key];
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}
