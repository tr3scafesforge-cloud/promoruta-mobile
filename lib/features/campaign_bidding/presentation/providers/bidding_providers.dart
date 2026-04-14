import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/providers/infrastructure_providers.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/features/campaign_bidding/data/datasources/remote/campaign_bidding_remote_data_source.dart';
import 'package:promoruta/features/campaign_bidding/data/repositories/campaign_bidding_repository_impl.dart';
import 'package:promoruta/features/campaign_bidding/domain/repositories/campaign_bidding_repository.dart';
import 'package:promoruta/features/campaign_bidding/domain/use_cases/campaign_bidding_use_cases.dart';

// ============ Data Sources ============

final campaignBiddingRemoteDataSourceProvider =
    Provider<CampaignBiddingRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CampaignBiddingRemoteDataSourceImpl(dio: dio);
});

// ============ Repositories ============

final campaignBiddingRepositoryProvider =
    Provider<CampaignBiddingRepository>((ref) {
  final remoteDataSource = ref.watch(campaignBiddingRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return CampaignBiddingRepositoryImpl(remoteDataSource, connectivityService);
});

// ============ Use Cases ============

final getCampaignBidsUseCaseProvider = Provider<GetCampaignBidsUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return GetCampaignBidsUseCase(repository);
});

final createBidUseCaseProvider = Provider<CreateBidUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return CreateBidUseCase(repository);
});

final updateBidUseCaseProvider = Provider<UpdateBidUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return UpdateBidUseCase(repository);
});

final withdrawBidUseCaseProvider = Provider<WithdrawBidUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return WithdrawBidUseCase(repository);
});

final acceptBidUseCaseProvider = Provider<AcceptBidUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return AcceptBidUseCase(repository);
});

final confirmPaymentUseCaseProvider = Provider<ConfirmPaymentUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return ConfirmPaymentUseCase(repository);
});

final retryPaymentCheckoutUseCaseProvider =
    Provider<RetryPaymentCheckoutUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return RetryPaymentCheckoutUseCase(repository);
});

final startCampaignUseCaseProvider = Provider<StartCampaignUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return StartCampaignUseCase(repository);
});

final completeCampaignUseCaseProvider =
    Provider<CompleteCampaignUseCase>((ref) {
  final repository = ref.watch(campaignBiddingRepositoryProvider);
  return CompleteCampaignUseCase(repository);
});

// ============ State Providers ============

final campaignBidsProvider = FutureProvider.autoDispose
    .family<CampaignBidsSummary, String>((ref, campaignId) async {
  final getCampaignBidsUseCase = ref.watch(getCampaignBidsUseCaseProvider);
  return await getCampaignBidsUseCase(campaignId);
});
