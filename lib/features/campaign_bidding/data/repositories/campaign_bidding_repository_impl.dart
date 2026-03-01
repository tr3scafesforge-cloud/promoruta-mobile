import 'package:dio/dio.dart';
import 'package:promoruta/core/models/app_error.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/core/models/payment_info.dart';
import 'package:promoruta/core/models/result.dart';
import 'package:promoruta/shared/services/connectivity_service.dart';
import 'package:promoruta/features/campaign_bidding/domain/repositories/campaign_bidding_repository.dart';

class CampaignBiddingRepositoryImpl implements CampaignBiddingRepository {
  final CampaignBiddingRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  CampaignBiddingRepositoryImpl(
    this._remoteDataSource,
    this._connectivityService,
  );

  @override
  Future<Result<CampaignBidsSummary, AppError>> getCampaignBids(
      String campaignId) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final summary = await _remoteDataSource.getCampaignBids(campaignId);
      return Result.success(summary);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<CampaignBid, AppError>> createBid({
    required String campaignId,
    required double proposedPrice,
    String? message,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final bid = await _remoteDataSource.createBid(
        campaignId: campaignId,
        proposedPrice: proposedPrice,
        message: message,
      );
      return Result.success(bid);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<CampaignBid, AppError>> updateBid({
    required String campaignId,
    required String bidId,
    required double proposedPrice,
    String? message,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final bid = await _remoteDataSource.updateBid(
        campaignId: campaignId,
        bidId: bidId,
        proposedPrice: proposedPrice,
        message: message,
      );
      return Result.success(bid);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<CampaignBid, AppError>> withdrawBid({
    required String campaignId,
    required String bidId,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final bid = await _remoteDataSource.withdrawBid(
        campaignId: campaignId,
        bidId: bidId,
      );
      return Result.success(bid);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<PaymentInfo, AppError>> acceptBid({
    required String campaignId,
    required String bidId,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final paymentInfo = await _remoteDataSource.acceptBid(
        campaignId: campaignId,
        bidId: bidId,
      );
      return Result.success(paymentInfo);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<PaymentInfo, AppError>> confirmPayment({
    required String campaignId,
    String? gatewayId,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final paymentInfo = await _remoteDataSource.confirmPayment(
        campaignId: campaignId,
        gatewayId: gatewayId,
      );
      return Result.success(paymentInfo);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<Campaign, AppError>> startCampaign(String campaignId) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final campaign = await _remoteDataSource.startCampaign(campaignId);
      return Result.success(campaign);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<Campaign, AppError>> completeCampaign(String campaignId) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      return Result.failure(NetworkError.noConnection());
    }

    try {
      final campaign = await _remoteDataSource.completeCampaign(campaignId);
      return Result.success(campaign);
    } catch (e, stackTrace) {
      return Result.failure(_mapException(e, stackTrace));
    }
  }

  AppError _mapException(Object error, StackTrace? stackTrace) {
    if (error is DioException) {
      return _mapDioException(error, stackTrace);
    }

    if (error is AppError) {
      return error;
    }

    if (error is FormatException) {
      return ParsingError.invalidJson(cause: error, stackTrace: stackTrace);
    }

    if (error is TypeError) {
      return ParsingError(
        message: 'Type error during parsing: ${error.toString()}',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return UnknownError.fromException(error, stackTrace);
  }

  AppError _mapDioException(DioException error, StackTrace? stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError.timeout(cause: error, stackTrace: stackTrace);
      case DioExceptionType.connectionError:
        return NetworkError.noConnection(cause: error, stackTrace: stackTrace);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == null) {
          return UnknownError.fromException(error, stackTrace);
        }

        switch (statusCode) {
          case 401:
            return AuthError.unauthorized(cause: error, stackTrace: stackTrace);
          case 403:
            return AuthError.forbidden(cause: error, stackTrace: stackTrace);
          case 404:
            return NotFoundError(
              message: 'Resource not found',
              cause: error,
              stackTrace: stackTrace,
            );
          case 422:
            final fieldErrors = _extractValidationErrors(responseData);
            return ValidationError.fromFields(fieldErrors,
                cause: error, stackTrace: stackTrace);
          case >= 500:
            return ServerError(
              message: 'Server error: $statusCode',
              statusCode: statusCode,
              cause: error,
              stackTrace: stackTrace,
            );
          default:
            return UnknownError(
              message: 'HTTP error: $statusCode',
              cause: error,
              stackTrace: stackTrace,
            );
        }

      case DioExceptionType.cancel:
        return NetworkError(
          message: 'Request was cancelled',
          isTransient: false,
          cause: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badCertificate:
        return NetworkError(
          message: 'Invalid SSL certificate',
          isTransient: false,
          cause: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.unknown:
        return UnknownError.fromException(error, stackTrace);
    }
  }

  Map<String, List<String>> _extractValidationErrors(dynamic responseData) {
    if (responseData == null) return {};

    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.map((e) => e.toString()).toList());
          }
          return MapEntry(key, [value.toString()]);
        });
      }

      final message = responseData['message'];
      if (message != null) {
        return {
          'general': [message.toString()]
        };
      }
    }

    return {};
  }
}
