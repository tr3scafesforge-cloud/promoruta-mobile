/// Media Upload Service - Usage Examples
library;
/// This file demonstrates how to use the media upload service with the canonical URL pattern:
/// /api/{modelType}/{modelId}/media
///
/// Available Model Types:
/// - users
/// - campaigns
/// - campaign-bids
/// - gps-tracks
/// - payments
/// - ratings
///
/// Available Media Roles:
/// - avatar
/// - gallery
/// - banner
/// - thumbnail
/// - document
/// - audio
/// - video

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/datasources/remote/media_remote_data_source.dart';
import 'package:promoruta/shared/providers/providers.dart';

/// Example 1: Upload audio to a campaign
Future<void> uploadCampaignAudio(
  WidgetRef ref,
  String campaignId,
  File audioFile,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    // Using convenience method
    final response = await mediaRepository.uploadCampaignMedia(
      campaignId: campaignId,
      file: audioFile,
      role: MediaRole.audio,
    );

    AppLogger.auth.i('Audio uploaded successfully!');
    AppLogger.auth.i('ID: ${response.id}');
    AppLogger.auth.i('URL: ${response.url}');
    AppLogger.auth.i('Path: ${response.path}');

    // Response example:
    // {
    //   "id": "019ae1f3-f694-71a5-a98d-f4b5e4081f6c",
    //   "role": "audio",
    //   "path": "campaigns/019a4222-051c-7223-b72f-ac9c8b9c0fd3/audio/eNH5iDn8jvkwgJ9lCi9kseYd0i09wYsiwJ8Ta7TY.mp3",
    //   "url": "https://storage.medinova.com.uy/promoruta/campaigns/019a4222-051c-7223-b72f-ac9c8b9c0fd3/audio/eNH5iDn8jvkwgJ9lCi9kseYd0i09wYsiwJ8Ta7TY.mp3",
    //   "created_at": "2025-12-03T02:04:13.000000Z",
    //   "updated_at": "2025-12-03T02:04:13.000000Z"
    // }
  } catch (e) {
    AppLogger.auth.e('Error uploading audio: $e');
  }
}

/// Example 2: Upload banner image to a campaign
Future<void> uploadCampaignBanner(
  WidgetRef ref,
  String campaignId,
  File bannerImage,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    // Using generic method
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.campaigns,
      modelId: campaignId,
      file: bannerImage,
      role: MediaRole.banner,
    );

    AppLogger.auth.i('Banner uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading banner: $e');
  }
}

/// Example 3: Upload user avatar
Future<void> uploadAvatar(
  WidgetRef ref,
  String userId,
  File avatarImage,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    // Using convenience method
    final response = await mediaRepository.uploadUserAvatar(
      userId: userId,
      file: avatarImage,
    );

    AppLogger.auth.i('Avatar uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading avatar: $e');
  }
}

/// Example 4: Upload user gallery image
Future<void> uploadGalleryImage(
  WidgetRef ref,
  String userId,
  File galleryImage,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    // Using convenience method
    final response = await mediaRepository.uploadUserGallery(
      userId: userId,
      file: galleryImage,
    );

    AppLogger.auth.i('Gallery image uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading gallery image: $e');
  }
}

/// Example 5: Upload document to campaign bid
Future<void> uploadBidDocument(
  WidgetRef ref,
  String bidId,
  File document,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.campaignBids,
      modelId: bidId,
      file: document,
      role: MediaRole.document,
    );

    AppLogger.auth.i('Document uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading document: $e');
  }
}

/// Example 6: Upload thumbnail for a campaign
Future<void> uploadCampaignThumbnail(
  WidgetRef ref,
  String campaignId,
  File thumbnail,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.campaigns,
      modelId: campaignId,
      file: thumbnail,
      role: MediaRole.thumbnail,
    );

    AppLogger.auth.i('Thumbnail uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading thumbnail: $e');
  }
}

/// Example 7: Upload video to a campaign
Future<void> uploadCampaignVideo(
  WidgetRef ref,
  String campaignId,
  File video,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.campaigns,
      modelId: campaignId,
      file: video,
      role: MediaRole.video,
    );

    AppLogger.auth.i('Video uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading video: $e');
  }
}

/// Example 8: Upload proof image for GPS track
Future<void> uploadGpsTrackProof(
  WidgetRef ref,
  String trackId,
  File proofImage,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.gpsTracks,
      modelId: trackId,
      file: proofImage,
      role: MediaRole.gallery, // or thumbnail
    );

    AppLogger.auth.i('GPS track proof uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading GPS track proof: $e');
  }
}

/// Example 9: Upload payment receipt
Future<void> uploadPaymentReceipt(
  WidgetRef ref,
  String paymentId,
  File receipt,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.payments,
      modelId: paymentId,
      file: receipt,
      role: MediaRole.document,
    );

    AppLogger.auth.i('Payment receipt uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading payment receipt: $e');
  }
}

/// Example 10: Upload rating image
Future<void> uploadRatingImage(
  WidgetRef ref,
  String ratingId,
  File image,
) async {
  final mediaRepository = ref.read(mediaRepositoryProvider);

  try {
    final response = await mediaRepository.uploadMedia(
      modelType: ModelType.ratings,
      modelId: ratingId,
      file: image,
      role: MediaRole.gallery,
    );

    AppLogger.auth.i('Rating image uploaded successfully!');
    AppLogger.auth.i('URL: ${response.url}');
  } catch (e) {
    AppLogger.auth.e('Error uploading rating image: $e');
  }
}
