import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/core/models/payment_info.dart';
import 'package:promoruta/core/models/result.dart';
import 'package:promoruta/core/models/app_error.dart';

abstract class CampaignBiddingRepository {
  Future<Result<CampaignBidsSummary, AppError>> getCampaignBids(
      String campaignId);
  Future<Result<CampaignBid, AppError>> createBid({
    required String campaignId,
    required double proposedPrice,
    String? message,
  });
  Future<Result<CampaignBid, AppError>> updateBid({
    required String campaignId,
    required String bidId,
    required double proposedPrice,
    String? message,
  });
  Future<Result<CampaignBid, AppError>> withdrawBid({
    required String campaignId,
    required String bidId,
  });
  Future<Result<PaymentInfo, AppError>> acceptBid({
    required String campaignId,
    required String bidId,
  });
  Future<Result<PaymentInfo, AppError>> confirmPayment({
    required String campaignId,
    String? gatewayId,
  });
  Future<Result<PaymentInfo, AppError>> retryPaymentCheckout(String campaignId);
  Future<Result<Campaign, AppError>> startCampaign(String campaignId);
  Future<Result<Campaign, AppError>> completeCampaign(String campaignId);
}

abstract class CampaignBiddingRemoteDataSource {
  Future<CampaignBidsSummary> getCampaignBids(String campaignId);
  Future<CampaignBid> createBid({
    required String campaignId,
    required double proposedPrice,
    String? message,
  });
  Future<CampaignBid> updateBid({
    required String campaignId,
    required String bidId,
    required double proposedPrice,
    String? message,
  });
  Future<CampaignBid> withdrawBid({
    required String campaignId,
    required String bidId,
  });
  Future<PaymentInfo> acceptBid({
    required String campaignId,
    required String bidId,
  });
  Future<PaymentInfo> confirmPayment({
    required String campaignId,
    String? gatewayId,
  });
  Future<PaymentInfo> retryPaymentCheckout(String campaignId);
  Future<Campaign> startCampaign(String campaignId);
  Future<Campaign> completeCampaign(String campaignId);
}
