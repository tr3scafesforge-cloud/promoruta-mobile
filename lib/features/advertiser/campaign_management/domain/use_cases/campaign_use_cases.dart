import 'dart:io';
import '../repositories/campaign_repository.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/models/app_error.dart';
import 'package:promoruta/core/models/campaign_query_params.dart';
import 'package:promoruta/shared/shared.dart';

// Re-export CampaignQueryParams as GetCampaignsParams for backward compatibility
export 'package:promoruta/core/models/campaign_query_params.dart';

/// Alias for CampaignQueryParams for backward compatibility
typedef GetCampaignsParams = CampaignQueryParams;

/// Use case for getting all campaigns
class GetCampaignsUseCase
    implements UseCase<List<model.Campaign>, GetCampaignsParams?> {
  final CampaignRepository _repository;

  GetCampaignsUseCase(this._repository);

  @override
  Future<List<model.Campaign>> call([GetCampaignsParams? params]) async {
    final result = await _repository.getCampaigns(
      status: params?.status,
      zone: params?.zone,
      createdBy: params?.createdBy,
      acceptedBy: params?.acceptedBy,
      upcoming: params?.upcoming,
      startTimeFrom: params?.startTimeFrom,
      startTimeTo: params?.startTimeTo,
      sortBy: params?.sortBy,
      sortOrder: params?.sortOrder,
      lat: params?.lat,
      lng: params?.lng,
      radius: params?.radius,
      page: params?.page,
      perPage: params?.perPage,
    );

    return result.fold(
      (campaigns) => campaigns,
      (error) => throw _toException(error),
    );
  }
}

/// Use case for getting a specific campaign by ID
class GetCampaignUseCase implements UseCase<model.Campaign?, String> {
  final CampaignRepository _repository;

  GetCampaignUseCase(this._repository);

  @override
  Future<model.Campaign?> call(String campaignId) async {
    final result = await _repository.getCampaign(campaignId);

    return result.fold(
      (campaign) => campaign,
      (error) {
        // Return null for not found, throw for other errors
        if (error is NotFoundError) {
          return null;
        }
        throw _toException(error);
      },
    );
  }
}

/// Parameters for creating a campaign
class CreateCampaignParams {
  final model.Campaign campaign;
  final File? audioFile;

  const CreateCampaignParams({
    required this.campaign,
    this.audioFile,
  });
}

/// Use case for creating a new campaign
class CreateCampaignUseCase
    implements UseCase<model.Campaign, CreateCampaignParams> {
  final CampaignRepository _repository;

  CreateCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(CreateCampaignParams params) async {
    final result = await _repository.createCampaign(
      params.campaign,
      audioFile: params.audioFile,
    );

    return result.fold(
      (campaign) => campaign,
      (error) => throw _toException(error),
    );
  }
}

/// Use case for updating an existing campaign
class UpdateCampaignUseCase implements UseCase<model.Campaign, model.Campaign> {
  final CampaignRepository _repository;

  UpdateCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(model.Campaign campaign) async {
    final result = await _repository.updateCampaign(campaign);

    return result.fold(
      (updated) => updated,
      (error) => throw _toException(error),
    );
  }
}

/// Use case for deleting a campaign
class DeleteCampaignUseCase implements UseCaseVoid<String> {
  final CampaignRepository _repository;

  DeleteCampaignUseCase(this._repository);

  @override
  Future<void> call(String campaignId) async {
    final result = await _repository.deleteCampaign(campaignId);

    result.fold(
      (_) {},
      (error) => throw _toException(error),
    );
  }
}

/// Parameters for cancelling a campaign
class CancelCampaignParams {
  final String campaignId;
  final String reason;

  const CancelCampaignParams({
    required this.campaignId,
    required this.reason,
  });
}

/// Use case for cancelling a campaign
class CancelCampaignUseCase
    implements UseCase<model.Campaign, CancelCampaignParams> {
  final CampaignRepository _repository;

  CancelCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(CancelCampaignParams params) async {
    final result =
        await _repository.cancelCampaign(params.campaignId, params.reason);

    return result.fold(
      (campaign) => campaign,
      (error) => throw _toException(error),
    );
  }
}

/// Converts AppError to Exception for backwards compatibility with existing code.
Exception _toException(AppError error) {
  return Exception(error.message);
}
