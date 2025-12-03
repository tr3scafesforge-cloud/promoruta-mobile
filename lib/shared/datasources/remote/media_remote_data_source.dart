import 'dart:io';
import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/repositories/auth_repository.dart';

/// Enum for model types
enum ModelType {
  users,
  campaigns,
  campaignBids,
  gpsTracks,
  payments,
  ratings;

  String get value {
    switch (this) {
      case ModelType.users:
        return 'users';
      case ModelType.campaigns:
        return 'campaigns';
      case ModelType.campaignBids:
        return 'campaign-bids';
      case ModelType.gpsTracks:
        return 'gps-tracks';
      case ModelType.payments:
        return 'payments';
      case ModelType.ratings:
        return 'ratings';
    }
  }
}

/// Enum for media roles/types
enum MediaRole {
  avatar,
  gallery,
  banner,
  thumbnail,
  document,
  audio,
  video;

  String get value => name;
}

/// Response model for media upload
class MediaUploadResponse {
  final String id;
  final String role;
  final String path;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MediaUploadResponse({
    required this.id,
    required this.role,
    required this.path,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      id: json['id'] as String,
      role: json['role'] as String,
      path: json['path'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'path': path,
      'url': url,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Abstract interface for media remote data source
abstract class MediaRemoteDataSource {
  /// Upload media file using the canonical pattern: /api/{modelType}/{modelId}/media
  ///
  /// [modelType] - The type of model (users, campaigns, etc.)
  /// [modelId] - The UUID of the model instance
  /// [file] - The file to upload
  /// [role] - The role/type of the media (avatar, audio, video, etc.)
  Future<MediaUploadResponse> uploadMedia({
    required ModelType modelType,
    required String modelId,
    required File file,
    required MediaRole role,
  });
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource _localDataSource;

  MediaRemoteDataSourceImpl({
    required this.dio,
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  /// Helper method to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final user = await _localDataSource.getUser();
    if (user == null) throw Exception('No user logged in');
    return {'Authorization': 'Bearer ${user.accessToken}'};
  }

  @override
  Future<MediaUploadResponse> uploadMedia({
    required ModelType modelType,
    required String modelId,
    required File file,
    required MediaRole role,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final fileName = file.path.split('/').last;

      // Create form data with file and role
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'role': role.value,
      });

      // Build canonical URL: /api/{modelType}/{modelId}/media
      final endpoint = '/${modelType.value}/$modelId/media';

      AppLogger.auth.i('Uploading ${role.value} file to ${modelType.value}/$modelId: $fileName');

      final response = await dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          AppLogger.auth.d('Upload progress: $progress%');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        AppLogger.auth.i('Media upload successful: ${data['id']}');

        return MediaUploadResponse.fromJson(data);
      } else {
        throw Exception('Failed to upload media: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Media upload failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      // Handle different error codes with user-friendly messages
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            throw Exception('Authentication failed. Please log in again.');
          case 413:
            throw Exception('File is too large. Maximum size is 10 MB.');
          case 415:
            throw Exception('Unsupported file type. Please check the file format.');
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
            throw Exception('Invalid file or parameters.');
          case 404:
            throw Exception('Resource not found.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception('Unable to upload media. Please try again.');
        }
      } else {
        // Network or other Dio errors
        throw Exception('Network error. Please check your connection and try again.');
      }
    } catch (e) {
      AppLogger.auth.e('Unexpected error during media upload: $e');
      throw Exception('Failed to upload media: $e');
    }
  }
}
