/// Campaign status enumeration
enum CampaignStatus { active, pending, completed, canceled, expired }

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

/// Campaign model.
class Campaign {
  final String? id; // Optional for creation
  final String title;
  final String? description; // Optional
  final String? advertiserId; // Optional - will be set by backend
  final DateTime? startDate; // Optional - using startTime instead
  final DateTime? endDate; // Optional - using endTime instead
  final CampaignStatus? status; // Optional - will be set by backend

  // New required fields from API
  final String? audioUrl;
  final String zone;
  final double suggestedPrice;
  final DateTime bidDeadline;
  final int audioDuration; // in seconds
  final double distance; // in kilometers
  final List<RouteCoordinate> routeCoordinates;
  final DateTime startTime;
  final DateTime endTime;

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
      suggestedPrice: (json['suggested_price'] as num).toDouble(),
      bidDeadline: DateTime.parse(json['bid_deadline'] as String),
      audioDuration: json['audio_duration'] as int,
      distance: (json['distance'] as num).toDouble(),
      routeCoordinates: (json['route_coordinates'] as List)
          .map((c) => RouteCoordinate.fromJson(c as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] != null
          ? CampaignStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => CampaignStatus.pending,
            )
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
    );
  }
}