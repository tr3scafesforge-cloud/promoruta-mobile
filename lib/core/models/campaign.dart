/// Campaign status enumeration
enum CampaignStatus {
  active,
  pending,
  completed,
  canceled,
  expired,
  created; // New status from API

  static CampaignStatus fromString(String status) {
    switch (status.toLowerCase()) {
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
      case 'created':
        return CampaignStatus.created;
      default:
        return CampaignStatus.pending;
    }
  }
}

/// Route coordinate model
class RouteCoordinate {
  final double lat;
  final double lng;

  const RouteCoordinate({
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory RouteCoordinate.fromJson(Map<String, dynamic> json) {
    return RouteCoordinate(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

/// Campaign user model (simplified User for campaign relations)
class CampaignUser {
  final String id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CampaignUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignUser.fromJson(Map<String, dynamic> json) {
    return CampaignUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Campaign model.
class Campaign {
  final String? id; // Optional for creation
  final String title;
  final String? description; // Optional
  final String? advertiserId; // Optional - will be set by backend (deprecated, use createdBy)
  final DateTime? startDate; // Optional - deprecated, use startTime
  final DateTime? endDate; // Optional - deprecated, use endTime
  final CampaignStatus? status; // Optional - will be set by backend

  // API fields
  final String? audioUrl;
  final String zone;
  final double suggestedPrice;
  final DateTime bidDeadline;
  final int audioDuration; // in seconds
  final double distance; // in kilometers
  final List<RouteCoordinate> routeCoordinates;
  final DateTime startTime;
  final DateTime endTime;

  // New fields from API response
  final CampaignUser? createdBy;
  final CampaignUser? acceptedBy;
  final String? selectedBidId;
  final double? finalPrice;
  final CampaignUser? lastUpdatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Campaign({
    this.id,
    required this.title,
    this.description,
    this.advertiserId,
    this.startDate,
    this.endDate,
    this.status,
    this.audioUrl,
    required this.zone,
    required this.suggestedPrice,
    required this.bidDeadline,
    required this.audioDuration,
    required this.distance,
    required this.routeCoordinates,
    required this.startTime,
    required this.endTime,
    this.createdBy,
    this.acceptedBy,
    this.selectedBidId,
    this.finalPrice,
    this.lastUpdatedBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (advertiserId != null) 'advertiser_id': advertiserId,
      if (audioUrl != null) 'audio_url': audioUrl,
      'zone': zone,
      'suggested_price': suggestedPrice,
      'bid_deadline': bidDeadline.toIso8601String(),
      'audio_duration': audioDuration,
      'distance': distance,
      'route_coordinates': routeCoordinates.map((c) => c.toJson()).toList(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      if (status != null) 'status': status!.name,
      if (createdBy != null) 'created_by': createdBy!.toJson(),
      if (acceptedBy != null) 'accepted_by': acceptedBy!.toJson(),
      if (selectedBidId != null) 'selected_bid_id': selectedBidId,
      if (finalPrice != null) 'final_price': finalPrice,
      if (lastUpdatedBy != null) 'last_updated_by': lastUpdatedBy!.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      advertiserId: json['advertiser_id'] as String?,
      audioUrl: json['audio_url'] as String?,
      zone: json['zone'] as String,
      suggestedPrice: json['suggested_price'] is String
          ? double.parse(json['suggested_price'] as String)
          : (json['suggested_price'] as num).toDouble(),
      bidDeadline: DateTime.parse(json['bid_deadline'] as String),
      audioDuration: json['audio_duration'] as int,
      distance: json['distance'] is String
          ? double.parse(json['distance'] as String)
          : (json['distance'] as num).toDouble(),
      routeCoordinates: (json['route_coordinates'] as List)
          .map((c) => RouteCoordinate.fromJson(c as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] != null
          ? CampaignStatus.fromString(json['status'] as String)
          : null,
      createdBy: json['created_by'] != null
          ? CampaignUser.fromJson(json['created_by'] as Map<String, dynamic>)
          : null,
      acceptedBy: json['accepted_by'] != null
          ? CampaignUser.fromJson(json['accepted_by'] as Map<String, dynamic>)
          : null,
      selectedBidId: json['selected_bid_id'] as String?,
      finalPrice: json['final_price'] != null
          ? (json['final_price'] is String
              ? double.parse(json['final_price'] as String)
              : (json['final_price'] as num).toDouble())
          : null,
      lastUpdatedBy: json['last_updated_by'] != null
          ? CampaignUser.fromJson(json['last_updated_by'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
    );
  }

  Campaign copyWith({
    String? id,
    String? title,
    String? description,
    String? advertiserId,
    DateTime? startDate,
    DateTime? endDate,
    CampaignStatus? status,
    String? audioUrl,
    String? zone,
    double? suggestedPrice,
    DateTime? bidDeadline,
    int? audioDuration,
    double? distance,
    List<RouteCoordinate>? routeCoordinates,
    DateTime? startTime,
    DateTime? endTime,
    CampaignUser? createdBy,
    CampaignUser? acceptedBy,
    String? selectedBidId,
    double? finalPrice,
    CampaignUser? lastUpdatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      advertiserId: advertiserId ?? this.advertiserId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      zone: zone ?? this.zone,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      bidDeadline: bidDeadline ?? this.bidDeadline,
      audioDuration: audioDuration ?? this.audioDuration,
      distance: distance ?? this.distance,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdBy: createdBy ?? this.createdBy,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      selectedBidId: selectedBidId ?? this.selectedBidId,
      finalPrice: finalPrice ?? this.finalPrice,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}