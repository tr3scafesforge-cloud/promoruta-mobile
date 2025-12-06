/// Media upload response from API
class MediaUploadResponse {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final int? duration;
  final int? size;
  final String mimeType;

  MediaUploadResponse({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.duration,
    this.size,
    required this.mimeType,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as int?,
      size: json['size'] as int?,
      mimeType: json['mime_type'] as String? ?? 'application/octet-stream',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (duration != null) 'duration': duration,
      if (size != null) 'size': size,
      'mime_type': mimeType,
    };
  }
}

/// Type of model the media is associated with
enum ModelType {
  campaign,
  user,
  promoter,
  advertisement;

  String get value {
    switch (this) {
      case ModelType.campaign:
        return 'campaign';
      case ModelType.user:
        return 'user';
      case ModelType.promoter:
        return 'promoter';
      case ModelType.advertisement:
        return 'advertisement';
    }
  }

  static ModelType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'campaign':
        return ModelType.campaign;
      case 'user':
        return ModelType.user;
      case 'promoter':
        return ModelType.promoter;
      case 'advertisement':
        return ModelType.advertisement;
      default:
        return ModelType.campaign;
    }
  }
}

/// Role of the media in the campaign
enum MediaRole {
  audio,
  image,
  video,
  thumbnail,
  banner;

  String get value {
    switch (this) {
      case MediaRole.audio:
        return 'audio';
      case MediaRole.image:
        return 'image';
      case MediaRole.video:
        return 'video';
      case MediaRole.thumbnail:
        return 'thumbnail';
      case MediaRole.banner:
        return 'banner';
    }
  }

  static MediaRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'audio':
        return MediaRole.audio;
      case 'image':
        return MediaRole.image;
      case 'video':
        return MediaRole.video;
      case 'thumbnail':
        return MediaRole.thumbnail;
      case 'banner':
        return MediaRole.banner;
      default:
        return MediaRole.image;
    }
  }
}
