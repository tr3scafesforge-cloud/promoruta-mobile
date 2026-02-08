import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/advertiser_kpi_stats.dart';
import 'package:promoruta/features/advertiser/campaign_creation/data/datasources/remote/media_remote_data_source.dart';

import '../../../domain/repositories/campaign_repository.dart';

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  final Dio dio;
  final MediaRemoteDataSource? mediaDataSource;

  CampaignRemoteDataSourceImpl({
    required this.dio,
    this.mediaDataSource,
  });

  @override
  Future<List<Campaign>> getCampaigns({
    String? status,
    String? zone,
    String? createdBy,
    String? acceptedBy,
    bool? upcoming,
    DateTime? startTimeFrom,
    DateTime? startTimeTo,
    String? sortBy,
    String? sortOrder,
    double? lat,
    double? lng,
    double? radius,
    int? page,
    int? perPage,
  }) async {
    try {
      final filters = <String>[];
      if (status != null) filters.add('status=$status');
      if (zone != null) filters.add('zone=$zone');
      if (createdBy != null) filters.add('created_by=$createdBy');
      if (acceptedBy != null) filters.add('accepted_by=$acceptedBy');
      if (upcoming != null) filters.add('upcoming=$upcoming');
      if (startTimeFrom != null) {
        filters.add('start_time_from=${startTimeFrom.toIso8601String()}');
      }
      if (startTimeTo != null) {
        filters.add('start_time_to=${startTimeTo.toIso8601String()}');
      }
      if (sortBy != null) filters.add('sort_by=$sortBy');
      if (sortOrder != null) filters.add('sort_order=$sortOrder');
      if (lat != null) filters.add('lat=$lat');
      if (lng != null) filters.add('lng=$lng');
      if (radius != null) filters.add('radius=$radius');
      if (page != null) filters.add('page=$page');
      if (perPage != null) filters.add('per_page=$perPage');

      AppLogger.auth.i(
          'Fetching campaigns list${filters.isNotEmpty ? ' with filters: ${filters.join(', ')}' : ''}');

      final queryParameters = <String, dynamic>{};
      if (status != null) queryParameters['status'] = status;
      if (zone != null) queryParameters['zone'] = zone;
      if (createdBy != null) queryParameters['created_by'] = createdBy;
      if (acceptedBy != null) queryParameters['accepted_by'] = acceptedBy;
      if (upcoming != null) queryParameters['upcoming'] = upcoming;
      if (startTimeFrom != null) {
        queryParameters['start_time_from'] = startTimeFrom.toIso8601String();
      }
      if (startTimeTo != null) {
        queryParameters['start_time_to'] = startTimeTo.toIso8601String();
      }
      if (sortBy != null) queryParameters['sort_by'] = sortBy;
      if (sortOrder != null) queryParameters['sort_order'] = sortOrder;
      if (lat != null) queryParameters['lat'] = lat;
      if (lng != null) queryParameters['lng'] = lng;
      if (radius != null) queryParameters['radius'] = radius;
      if (page != null) queryParameters['page'] = page;
      if (perPage != null) queryParameters['per_page'] = perPage;

      final response = await dio.get(
        '/campaigns',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        AppLogger.auth.i(
            'Campaigns fetched successfully: ${data is List ? data.length : 0} campaigns');

        // Handle both array and object with data property
        final List campaigns =
            data is List ? data : (data['data'] as List? ?? []);

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
      AppLogger.auth
          .e('Fetch campaign failed: ${e.response?.statusCode} - ${e.message}');

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
  Future<Campaign> createCampaign(Campaign campaign, {File? audioFile}) async {
    try {
      Campaign campaignToCreate = campaign;

      // STEP 1: If audio file provided, set placeholder URL
      if (audioFile != null) {
        AppLogger.auth
            .i('Audio file provided, creating campaign with placeholder URL');
        campaignToCreate = campaign.copyWith(
          audioUrl: 'https://placeholder.com/audio.mp3',
        );
      }

      // STEP 2: Create campaign (with placeholder URL if audio file exists)
      final campaignData = campaignToCreate.toJson();
      AppLogger.auth.i('Creating campaign: ${campaign.title}');
      AppLogger.auth.d('Campaign POST body: $campaignData');

      final response = await dio.post(
        '/campaigns',
        data: campaignData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        AppLogger.auth.d('Response data type: ${responseData.runtimeType}');
        AppLogger.auth.d('Response data: $responseData');

        Map<String, dynamic> json;
        try {
          // Parse JSON if response is a string
          if (responseData is String) {
            json = jsonDecode(responseData) as Map<String, dynamic>;
          } else if (responseData is Map<String, dynamic>) {
            json = responseData;
          } else if (responseData is Map) {
            json = Map<String, dynamic>.from(responseData);
          } else {
            throw Exception(
                'Unexpected response data type: ${responseData.runtimeType}');
          }
        } catch (e) {
          AppLogger.auth.e('Failed to parse response data: $e');
          AppLogger.auth.e('Raw response: $responseData');
          rethrow;
        }

        final createdCampaign = Campaign.fromJson(json);
        AppLogger.auth
            .i('Campaign created successfully: ${createdCampaign.id}');

        // STEP 3: Upload audio file if provided
        if (audioFile != null && createdCampaign.id != null) {
          final mediaSource = mediaDataSource;
          if (mediaSource == null) {
            AppLogger.auth.w(
                'Media data source not available, returning campaign with placeholder URL');
            return createdCampaign;
          }

          try {
            // Upload audio to /campaigns/{id}/media
            AppLogger.auth
                .i('Uploading audio to campaign: ${createdCampaign.id}');
            final uploadResponse = await mediaSource.uploadMedia(
              modelType: ModelType.campaigns,
              modelId: createdCampaign.id!,
              file: audioFile,
              role: MediaRole.audio,
            );

            AppLogger.auth
                .i('Audio uploaded successfully: ${uploadResponse.url}');

            // STEP 4: Update campaign with real audio URL
            final updatedCampaign =
                createdCampaign.copyWith(audioUrl: uploadResponse.url);

            AppLogger.auth.i('Updating campaign with real audio URL');
            final updateResponse = await dio.put(
              '/campaigns/${createdCampaign.id}',
              data: updatedCampaign.toJson(),
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

            if (updateResponse.statusCode == 200) {
              AppLogger.auth
                  .i('Campaign updated with real audio URL successfully');

              final updateData = updateResponse.data;
              final updateJson = updateData is String
                  ? jsonDecode(updateData) as Map<String, dynamic>
                  : updateData as Map<String, dynamic>;

              return Campaign.fromJson(updateJson);
            } else {
              AppLogger.auth.w(
                  'Failed to update campaign with audio URL, returning campaign with uploaded URL');
              return updatedCampaign;
            }
          } catch (uploadError) {
            AppLogger.auth.e('Failed to upload/update audio: $uploadError');
            // Return the created campaign even if audio upload fails
            return createdCampaign;
          }
        }

        return createdCampaign;
      } else {
        throw Exception('Failed to create campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // For 401 errors, the TokenRefreshInterceptor should have already handled it
      // If we still get a 401 here, it means token refresh failed
      if (e.response?.statusCode == 401) {
        AppLogger.auth.e('Authentication failed - token refresh unsuccessful');
        throw Exception('Session expired. Please log in again.');
      }

      AppLogger.auth.e(
          'Campaign creation failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            // Handle validation errors
            Map<String, dynamic>? errorMap;
            if (responseData is String) {
              try {
                errorMap = jsonDecode(responseData) as Map<String, dynamic>;
              } catch (e) {
                AppLogger.auth.e('Failed to parse error response: $e');
              }
            } else if (responseData is Map) {
              errorMap = Map<String, dynamic>.from(responseData);
            }

            if (errorMap != null && errorMap.containsKey('message')) {
              throw Exception(errorMap['message'].toString());
            }
            if (errorMap != null && errorMap.containsKey('errors')) {
              final errors = errorMap['errors'];
              if (errors is Map && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                } else if (firstError is String) {
                  throw Exception(firstError);
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
        throw Exception(
            'Network error. Please check your connection and try again.');
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
      AppLogger.auth.e(
          'Campaign update failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

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
        throw Exception(
            'Network error. Please check your connection and try again.');
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
      AppLogger.auth.e(
          'Campaign deletion failed: ${e.response?.statusCode} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 404:
            throw Exception('Campaign not found.');
          case 403:
            throw Exception(
                'You do not have permission to delete this campaign.');
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

  @override
  Future<Campaign> cancelCampaign(String id, String reason) async {
    try {
      AppLogger.auth.i('Cancelling campaign: $id');

      final response = await dio.post(
        '/campaigns/$id/cancel',
        data: {'reason': reason},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        AppLogger.auth
            .i('Campaign cancelled successfully: ${json['campaign']['id']}');
        return Campaign.fromJson(json['campaign']);
      } else {
        throw Exception('Failed to cancel campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Campaign cancellation failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 404:
            throw Exception('Campaign not found.');
          case 403:
            throw Exception(
                'You do not have permission to cancel this campaign.');
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
            throw Exception('Invalid cancellation request.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception('Unable to cancel campaign. Please try again.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    } catch (e) {
      AppLogger.auth.e('Unexpected error during campaign cancellation: $e');
      throw Exception('Failed to cancel campaign: $e');
    }
  }

  @override
  Future<AdvertiserKpiStats> getKpiStats() async {
    try {
      AppLogger.auth.i('Fetching advertiser KPI stats');

      final response = await dio.get(
        '/advertiser/kpi-stats',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        AppLogger.auth.i('KPI stats fetched successfully');
        return AdvertiserKpiStats.fromJson(json);
      } else {
        throw Exception('Failed to fetch KPI stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Fetch KPI stats failed: ${e.response?.statusCode} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 404:
            throw Exception('KPI stats endpoint not found.');
          default:
            throw Exception('Failed to fetch KPI stats.');
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.auth.e('Unexpected error fetching KPI stats: $e');
      throw Exception('Failed to fetch KPI stats: $e');
    }
  }
}
