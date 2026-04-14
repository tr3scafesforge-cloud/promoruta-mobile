import 'package:promoruta/core/models/app_error.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/core/models/payment_info.dart';
import 'package:promoruta/shared/shared.dart';
import '../repositories/campaign_bidding_repository.dart';

class GetCampaignBidsUseCase implements UseCase<CampaignBidsSummary, String> {
  final CampaignBiddingRepository _repository;

  GetCampaignBidsUseCase(this._repository);

  @override
  Future<CampaignBidsSummary> call(String campaignId) async {
    final result = await _repository.getCampaignBids(campaignId);
    return result.fold(
      (summary) => summary,
      (error) => throw _toException(error),
    );
  }
}

class CreateBidParams {
  final String campaignId;
  final double proposedPrice;
  final String? message;

  const CreateBidParams({
    required this.campaignId,
    required this.proposedPrice,
    this.message,
  });
}

class CreateBidUseCase implements UseCase<CampaignBid, CreateBidParams> {
  final CampaignBiddingRepository _repository;

  CreateBidUseCase(this._repository);

  @override
  Future<CampaignBid> call(CreateBidParams params) async {
    final result = await _repository.createBid(
      campaignId: params.campaignId,
      proposedPrice: params.proposedPrice,
      message: params.message,
    );
    return result.fold(
      (bid) => bid,
      (error) => throw _toException(error),
    );
  }
}

class UpdateBidParams {
  final String campaignId;
  final String bidId;
  final double proposedPrice;
  final String? message;

  const UpdateBidParams({
    required this.campaignId,
    required this.bidId,
    required this.proposedPrice,
    this.message,
  });
}

class UpdateBidUseCase implements UseCase<CampaignBid, UpdateBidParams> {
  final CampaignBiddingRepository _repository;

  UpdateBidUseCase(this._repository);

  @override
  Future<CampaignBid> call(UpdateBidParams params) async {
    final result = await _repository.updateBid(
      campaignId: params.campaignId,
      bidId: params.bidId,
      proposedPrice: params.proposedPrice,
      message: params.message,
    );
    return result.fold(
      (bid) => bid,
      (error) => throw _toException(error),
    );
  }
}

class WithdrawBidParams {
  final String campaignId;
  final String bidId;

  const WithdrawBidParams({
    required this.campaignId,
    required this.bidId,
  });
}

class WithdrawBidUseCase implements UseCase<CampaignBid, WithdrawBidParams> {
  final CampaignBiddingRepository _repository;

  WithdrawBidUseCase(this._repository);

  @override
  Future<CampaignBid> call(WithdrawBidParams params) async {
    final result = await _repository.withdrawBid(
      campaignId: params.campaignId,
      bidId: params.bidId,
    );
    return result.fold(
      (bid) => bid,
      (error) => throw _toException(error),
    );
  }
}

class AcceptBidParams {
  final String campaignId;
  final String bidId;

  const AcceptBidParams({
    required this.campaignId,
    required this.bidId,
  });
}

class AcceptBidUseCase implements UseCase<PaymentInfo, AcceptBidParams> {
  final CampaignBiddingRepository _repository;

  AcceptBidUseCase(this._repository);

  @override
  Future<PaymentInfo> call(AcceptBidParams params) async {
    final result = await _repository.acceptBid(
      campaignId: params.campaignId,
      bidId: params.bidId,
    );
    return result.fold(
      (info) => info,
      (error) => throw _toException(error),
    );
  }
}

class ConfirmPaymentParams {
  final String campaignId;
  final String? gatewayId;

  const ConfirmPaymentParams({
    required this.campaignId,
    this.gatewayId,
  });
}

class ConfirmPaymentUseCase
    implements UseCase<PaymentInfo, ConfirmPaymentParams> {
  final CampaignBiddingRepository _repository;

  ConfirmPaymentUseCase(this._repository);

  @override
  Future<PaymentInfo> call(ConfirmPaymentParams params) async {
    final result = await _repository.confirmPayment(
      campaignId: params.campaignId,
      gatewayId: params.gatewayId,
    );
    return result.fold(
      (info) => info,
      (error) => throw _toException(error),
    );
  }
}

class RetryPaymentCheckoutUseCase implements UseCase<PaymentInfo, String> {
  final CampaignBiddingRepository _repository;

  RetryPaymentCheckoutUseCase(this._repository);

  @override
  Future<PaymentInfo> call(String campaignId) async {
    final result = await _repository.retryPaymentCheckout(campaignId);
    return result.fold(
      (info) => info,
      (error) => throw _toException(error),
    );
  }
}

class StartCampaignUseCase implements UseCase<Campaign, String> {
  final CampaignBiddingRepository _repository;

  StartCampaignUseCase(this._repository);

  @override
  Future<Campaign> call(String campaignId) async {
    final result = await _repository.startCampaign(campaignId);
    return result.fold(
      (campaign) => campaign,
      (error) => throw _toException(error),
    );
  }
}

class CompleteCampaignUseCase implements UseCase<Campaign, String> {
  final CampaignBiddingRepository _repository;

  CompleteCampaignUseCase(this._repository);

  @override
  Future<Campaign> call(String campaignId) async {
    final result = await _repository.completeCampaign(campaignId);
    return result.fold(
      (campaign) => campaign,
      (error) => throw _toException(error),
    );
  }
}

Exception _toException(AppError error) {
  return Exception(error.message);
}
