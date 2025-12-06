import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/core/models/campaign.dart';

import '../../../domain/repositories/campaign_repository.dart';

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  final Dio dio;

  CampaignRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<List<Campaign>> getCampaigns() async {
    try {
      AppLogger.auth.i('Fetching campaigns list');

      final response = await dio.get(
        '/campaigns',
        options: Options(
          headers: {
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
    } catch (e) {
      AppLogger.auth.e('Unexpected error fetching campaigns: $e');
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  @override
  Future<Campaign> getCampaign(String id) async {
    try {
      AppLogger.auth.i('Fetching campaign: $id');

      final response = await dio.get(
        '/campaigns/$id',
        options: Options(
          headers: {
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
      AppLogger.auth.i('Creating campaign: ${campaign.title}');

      final response = await dio.post(
        '/campaigns',
        data: campaign.toJson(),
        options: Options(
          headers: {
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
      AppLogger.auth.i('Updating campaign: ${campaign.id}');

      final response = await dio.put(
        '/campaigns/${campaign.id}',
        data: campaign.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        AppLogger.auth.i('Campaign updated successfully: ${json['id']}');
        return Campaign.fromJson(json);
      } else {
        throw Exception('Failed to update campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Campaign update failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 404:
            throw Exception('Campaign not found.');
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
            throw Exception('Unable to update campaign. Please try again.');
        }
      } else {
        throw Exception('Network error. Please check your connection and try again.');
      }
    } catch (e) {
      AppLogger.auth.e('Unexpected error during campaign update: $e');
      throw Exception('Failed to update campaign: $e');
    }
  }

  @override
  Future<void> deleteCampaign(String id) async {
    try {
      AppLogger.auth.i('Deleting campaign: $id');

      final response = await dio.delete(
        '/campaigns/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        AppLogger.auth.i('Campaign deleted successfully: $id');
      } else {
        throw Exception('Failed to delete campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Campaign deletion failed: ${e.response?.statusCode} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 404:
            throw Exception('Campaign not found.');
          case 403:
            throw Exception('You do not have permission to delete this campaign.');
          default:
            throw Exception('Unable to delete campaign.');
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.auth.e('Unexpected error during campaign deletion: $e');
      throw Exception('Failed to delete campaign: $e');
    }
  }
}
