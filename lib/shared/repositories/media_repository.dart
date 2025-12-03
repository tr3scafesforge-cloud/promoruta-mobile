import 'dart:io';
import 'package:promoruta/shared/datasources/remote/media_remote_data_source.dart';

/// Abstract interface for media repository
abstract class MediaRepository {
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

  /// Convenience method: Upload media to a campaign
  Future<MediaUploadResponse> uploadCampaignMedia({
    required String campaignId,
    required File file,
    required MediaRole role,
  });

  /// Convenience method: Upload avatar for a user
  Future<MediaUploadResponse> uploadUserAvatar({
    required String userId,
    required File file,
  });

  /// Convenience method: Upload gallery image for a user
  Future<MediaUploadResponse> uploadUserGallery({
    required String userId,
    required File file,
  });
}

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource _remoteDataSource;

  MediaRepositoryImpl({
    required MediaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<MediaUploadResponse> uploadMedia({
    required ModelType modelType,
    required String modelId,
    required File file,
    required MediaRole role,
  }) async {
    return await _remoteDataSource.uploadMedia(
      modelType: modelType,
      modelId: modelId,
      file: file,
      role: role,
    );
  }

  @override
  Future<MediaUploadResponse> uploadCampaignMedia({
    required String campaignId,
    required File file,
    required MediaRole role,
  }) {
    return uploadMedia(
      modelType: ModelType.campaigns,
      modelId: campaignId,
      file: file,
      role: role,
    );
  }

  @override
  Future<MediaUploadResponse> uploadUserAvatar({
    required String userId,
    required File file,
  }) {
    return uploadMedia(
      modelType: ModelType.users,
      modelId: userId,
      file: file,
      role: MediaRole.avatar,
    );
  }

  @override
  Future<MediaUploadResponse> uploadUserGallery({
    required String userId,
    required File file,
  }) {
    return uploadMedia(
      modelType: ModelType.users,
      modelId: userId,
      file: file,
      role: MediaRole.gallery,
    );
  }
}
