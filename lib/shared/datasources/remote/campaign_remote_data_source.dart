import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';

import '../../../core/models/campaign.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/campaign_repository.dart';

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource _localDataSource;

  CampaignRemoteDataSourceImpl({
    required this.dio,
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  /// Helper method to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final user = await _localDataSource.getUser();
    if (user == null) throw Exception('No user logged in');
    return {'Authorization': 'Bearer ${user.accessToken}'};
  }

  CampaignStatus _parseStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'active':
        return CampaignStatus.active;
      case 'pending':
        return CampaignStatus.pending;
      case 'completed':
        return CampaignStatus.completed;
      case 'canceled':
        return CampaignStatus.canceled;
      case 'expired':
        return CampaignStatus.expired;
      default:
        return CampaignStatus.active;
    }
  }

  @override
  Future<List<Campaign>> getCampaigns() async {
    try {
      final headers = await _getAuthHeaders();

      AppLogger.auth.i('Fetching campaigns list');

      final response = await dio.get(
        '/campaigns',
        options: Options(
          headers: {
            ...headers,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        AppLogger.auth.i('Campaigns fetched successfully: ${data is List ? data.length : 0} campaigns');

        // Handle both array and object with data property
        final List campaigns = data is List ? data : (data['data'] as List? ?? []);

        return campaigns
            .map((json) => Campaign.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch campaigns: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Fetch campaigns failed: ${e.response?.statusCode} - ${e.message}');

      if (e.response != null && e.response!.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.auth.e('Unexpected error fetching campaigns: $e');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  @override
  Future<Campaign> getCampaign(String id) async {
    try {
      final headers = await _getAuthHeaders();

      AppLogger.auth.i('Fetching campaign: $id');

      final response = await dio.get(
        '/campaigns/$id',
        options: Options(
          headers: {
            ...headers,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        AppLogger.auth.i('Campaign fetched successfully: ${json['id']}');
        return Campaign.fromJson(json);
      } else {
        throw Exception('Failed to fetch campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Fetch campaign failed: ${e.response?.statusCode} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 401:
            throw Exception('Authentication failed. Please log in again.');
          case 404:
            throw Exception('Campaign not found.');
          default:
            throw Exception('Failed to fetch campaign.');
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.auth.e('Unexpected error fetching campaign: $e');
      throw Exception('Failed to fetch campaign: $e');
    }
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    try {
      final headers = await _getAuthHeaders();

      AppLogger.auth.i('Creating campaign: ${campaign.title}');

      final response = await dio.post(
        '/campaigns',
        data: campaign.toJson(),
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data;
        AppLogger.auth.i('Campaign created successfully: ${json['id']}');
        return Campaign.fromJson(json);
      } else {
        throw Exception('Failed to create campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Campaign creation failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            throw Exception('Authentication failed. Please log in again.');
          case 422:
            // Handle validation errors
            if (responseData is Map && responseData.containsKey('message')) {
              throw Exception(responseData['message'].toString());
            }
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Invalid campaign data.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception('Unable to create campaign. Please try again.');
        }
      } else {
        throw Exception('Network error. Please check your connection and try again.');
      }
    } catch (e) {
      AppLogger.auth.e('Unexpected error during campaign creation: $e');
      throw Exception('Failed to create campaign: $e');
    }
  }

  @override
  Future<Campaign> updateCampaign(Campaign campaign) async {
    try {
      final response = await dio.put(
        'campaigns/${campaign.id}',
        data: {
          'title': campaign.title,
          'description': campaign.description,
          'advertiserId': campaign.advertiserId,
          'startDate': campaign.startDate.toIso8601String(),
          'endDate': campaign.endDate.toIso8601String(),
          'status': campaign.status.name,
        },
      );

      if (response.statusCode == 200) {
        final json = response.data;
        return Campaign(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          advertiserId: json['advertiserId'],
          startDate: DateTime.parse(json['startDate']),
          endDate: DateTime.parse(json['endDate']),
          status: _parseStatus(json['status'] ?? 'active'),
        );
      } else {
        throw Exception('Failed to update campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> deleteCampaign(String id) async {
    try {
      final response = await dio.delete('campaigns/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}