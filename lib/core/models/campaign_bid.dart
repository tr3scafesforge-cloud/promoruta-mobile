import 'package:promoruta/core/models/payment_status.dart';

/// Campaign bid status enumeration
enum CampaignBidStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  static CampaignBidStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return CampaignBidStatus.pending;
      case 'accepted':
        return CampaignBidStatus.accepted;
      case 'rejected':
        return CampaignBidStatus.rejected;
      case 'withdrawn':
        return CampaignBidStatus.withdrawn;
      default:
        return CampaignBidStatus.pending;
    }
  }

  String get apiValue => name;
}

class PromoterProfileSummary {
  final String name;
  final String? avatarUrl;
  final double averageRating;
  final int completedCampaignsCount;

  const PromoterProfileSummary({
    required this.name,
    this.avatarUrl,
    required this.averageRating,
    required this.completedCampaignsCount,
  });

  factory PromoterProfileSummary.fromJson(Map<String, dynamic> json) {
    return PromoterProfileSummary(
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      averageRating: json['average_rating'] is String
          ? double.parse(json['average_rating'] as String)
          : (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      completedCampaignsCount: json['completed_campaigns_count'] as int? ?? 0,
    );
  }
}

class CampaignBid {
  final String id;
  final String promoterId;
  final double proposedPrice;
  final String? message;
  final CampaignBidStatus status;
  final PromoterProfileSummary? promoterProfile;

  const CampaignBid({
    required this.id,
    required this.promoterId,
    required this.proposedPrice,
    this.message,
    required this.status,
    this.promoterProfile,
  });

  factory CampaignBid.fromJson(Map<String, dynamic> json) {
    return CampaignBid(
      id: json['id'] as String,
      promoterId: json['promoter_id'] as String? ?? '',
      proposedPrice: json['proposed_price'] is String
          ? double.parse(json['proposed_price'] as String)
          : (json['proposed_price'] as num).toDouble(),
      message: json['message'] as String?,
      status: json['status'] != null
          ? CampaignBidStatus.fromString(json['status'] as String)
          : CampaignBidStatus.pending,
      promoterProfile: json['promoter_profile'] != null
          ? PromoterProfileSummary.fromJson(
              json['promoter_profile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promoter_id': promoterId,
      'proposed_price': proposedPrice,
      if (message != null) 'message': message,
      'status': status.apiValue,
    };
  }
}

class CampaignBidsSummary {
  final String campaignId;
  final String? campaignStatus;
  final DateTime? bidDeadline;
  final List<CampaignBid> bids;
  final PaymentStatus? paymentStatus;

  const CampaignBidsSummary({
    required this.campaignId,
    required this.bids,
    this.campaignStatus,
    this.bidDeadline,
    this.paymentStatus,
  });

  factory CampaignBidsSummary.fromJson(Map<String, dynamic> json) {
    final bidsList = (json['bids'] as List?) ?? const [];
    return CampaignBidsSummary(
      campaignId: json['campaign_id'] as String? ?? '',
      campaignStatus: json['status'] as String?,
      bidDeadline: json['bid_deadline'] != null
          ? DateTime.parse(json['bid_deadline'] as String)
          : null,
      bids: bidsList
          .map((bid) => CampaignBid.fromJson(bid as Map<String, dynamic>))
          .toList(),
      paymentStatus: json['payment_status'] != null
          ? PaymentStatus.fromString(json['payment_status'] as String)
          : null,
    );
  }
}
