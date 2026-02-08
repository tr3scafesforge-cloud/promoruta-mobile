/// Parameters for querying campaigns
///
/// This is a shared model used by both advertiser and promoter features
/// to filter and query campaign lists.
///
/// Available status values: pending, created, accepted, in_progress, completed, cancelled, expired
/// Sort by values: created_at, start_time, suggested_price
class CampaignQueryParams {
  final String? status;
  final String? zone;
  final String? createdBy;
  final String? acceptedBy;
  final bool? upcoming;
  final DateTime? startTimeFrom;
  final DateTime? startTimeTo;
  final String? sortBy;
  final String? sortOrder;
  final double? lat;
  final double? lng;
  final double? radius;
  final int? page;
  final int? perPage;

  const CampaignQueryParams({
    this.status,
    this.zone,
    this.createdBy,
    this.acceptedBy,
    this.upcoming,
    this.startTimeFrom,
    this.startTimeTo,
    this.sortBy,
    this.sortOrder,
    this.lat,
    this.lng,
    this.radius,
    this.page,
    this.perPage,
  });

  /// Creates a copy with updated values
  CampaignQueryParams copyWith({
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
  }) {
    return CampaignQueryParams(
      status: status ?? this.status,
      zone: zone ?? this.zone,
      createdBy: createdBy ?? this.createdBy,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      upcoming: upcoming ?? this.upcoming,
      startTimeFrom: startTimeFrom ?? this.startTimeFrom,
      startTimeTo: startTimeTo ?? this.startTimeTo,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}
