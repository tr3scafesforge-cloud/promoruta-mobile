import 'dart:io';
import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/models/advertiser_kpi_stats.dart';
import 'package:promoruta/core/models/result.dart';
import 'package:promoruta/core/models/app_error.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/shared.dart';
import '../../domain/repositories/campaign_repository.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignLocalDataSource _localDataSource;
  final CampaignRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  CampaignRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivityService,
  );

  @override
  Future<Result<List<model.Campaign>, AppError>> getCampaigns({
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
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final remoteCampaigns = await _remoteDataSource.getCampaigns(
          status: status,
          zone: zone,
          createdBy: createdBy,
          acceptedBy: acceptedBy,
          upcoming: upcoming,
          startTimeFrom: startTimeFrom,
          startTimeTo: startTimeTo,
          sortBy: sortBy,
          sortOrder: sortOrder,
          lat: lat,
          lng: lng,
          radius: radius,
          page: page,
          perPage: perPage,
        );

        // Try to update local cache, but don't fail if it errors
        try {
          await _localDataSource.saveCampaigns(remoteCampaigns);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return Result.success(remoteCampaigns);
      } catch (e, stackTrace) {
        // Remote failed, try local as fallback
        try {
          final localCampaigns = await _localDataSource.getCampaigns();
          return Result.success(localCampaigns);
        } catch (localError) {
          // Both failed, return remote error
          return Result.failure(_mapException(e, stackTrace));
        }
      }
    } else {
      // Offline: try local data
      try {
        final localCampaigns = await _localDataSource.getCampaigns();
        return Result.success(localCampaigns);
      } catch (e, stackTrace) {
        return Result.failure(NetworkError.noConnection(
          cause: e,
          stackTrace: stackTrace,
        ));
      }
    }
  }

  @override
  Future<Result<model.Campaign, AppError>> getCampaign(String id) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final remoteCampaign = await _remoteDataSource.getCampaign(id);

        // Try to update local cache
        try {
          await _localDataSource.saveCampaign(remoteCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return Result.success(remoteCampaign);
      } catch (e, stackTrace) {
        // Remote failed, try local as fallback
        try {
          final localCampaign = await _localDataSource.getCampaign(id);
          if (localCampaign != null) {
            return Result.success(localCampaign);
          }
        } catch (localError) {
          // Ignore local error
        }
        return Result.failure(_mapException(e, stackTrace));
      }
    } else {
      // Offline: try local data
      try {
        final localCampaign = await _localDataSource.getCampaign(id);
        if (localCampaign != null) {
          return Result.success(localCampaign);
        }
        return Result.failure(NotFoundError.resource('Campaign', id));
      } catch (e, stackTrace) {
        return Result.failure(NetworkError.noConnection(
          cause: e,
          stackTrace: stackTrace,
        ));
      }
    }
  }

  @override
  Future<Result<model.Campaign, AppError>> createCampaign(
      model.Campaign campaign,
      {File? audioFile}) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final createdCampaign = await _remoteDataSource.createCampaign(campaign,
            audioFile: audioFile);

        // Try to save locally
        try {
          await _localDataSource.saveCampaign(createdCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return Result.success(createdCampaign);
      } catch (e, stackTrace) {
        // If remote fails, try save locally for later sync
        try {
          await _localDataSource.saveCampaign(campaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }
        return Result.failure(_mapException(e, stackTrace));
      }
    } else {
      // Offline: save locally for later sync
      try {
        await _localDataSource.saveCampaign(campaign);
      } catch (localError) {
        AppLogger.auth.w('Could not save to local cache: $localError');
      }
      return Result.failure(NetworkError.noConnection());
    }
  }

  @override
  Future<Result<model.Campaign, AppError>> updateCampaign(
      model.Campaign campaign) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final updatedCampaign =
            await _remoteDataSource.updateCampaign(campaign);

        // Try to update local cache
        try {
          await _localDataSource.saveCampaign(updatedCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return Result.success(updatedCampaign);
      } catch (e, stackTrace) {
        // If remote fails, try update locally
        try {
          await _localDataSource.saveCampaign(campaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }
        return Result.failure(_mapException(e, stackTrace));
      }
    } else {
      // Offline: update locally
      try {
        await _localDataSource.saveCampaign(campaign);
      } catch (localError) {
        AppLogger.auth.w('Could not save to local cache: $localError');
      }
      return Result.failure(NetworkError.noConnection());
    }
  }

  @override
  Future<Result<void, AppError>> deleteCampaign(String id) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        await _remoteDataSource.deleteCampaign(id);

        // Try to remove from local
        try {
          await _localDataSource.deleteCampaign(id);
        } catch (localError) {
          AppLogger.auth.w('Could not delete from local cache: $localError');
        }

        return Result.success(null);
      } catch (e, stackTrace) {
        // If remote fails, try mark for deletion locally
        try {
          await _localDataSource.deleteCampaign(id);
        } catch (localError) {
          AppLogger.auth.w('Could not delete from local cache: $localError');
        }
        return Result.failure(_mapException(e, stackTrace));
      }
    } else {
      // Offline: delete locally
      try {
        await _localDataSource.deleteCampaign(id);
      } catch (localError) {
        AppLogger.auth.w('Could not delete from local cache: $localError');
      }
      return Result.failure(NetworkError.noConnection());
    }
  }

  @override
  Future<Result<model.Campaign, AppError>> cancelCampaign(
      String id, String reason) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final cancelledCampaign =
            await _remoteDataSource.cancelCampaign(id, reason);

        // Try to update local cache
        try {
          await _localDataSource.saveCampaign(cancelledCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return Result.success(cancelledCampaign);
      } catch (e, stackTrace) {
        return Result.failure(_mapException(e, stackTrace));
      }
    } else {
      return Result.failure(NetworkError.noConnection());
    }
  }

  @override
  Future<Result<AdvertiserKpiStats, AppError>> getKpiStats() async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final kpiStats = await _remoteDataSource.getKpiStats();
        return Result.success(kpiStats);
      } catch (e, stackTrace) {
        AppLogger.auth.e('Failed to fetch KPI stats: $e');
        return Result.failure(_mapException(e, stackTrace));
      }
    } else {
      return Result.failure(NetworkError.noConnection());
    }
  }

  /// Maps exceptions to appropriate AppError types.
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

  /// Maps DioException to appropriate AppError types.
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
            // Try to extract validation errors from response
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

  /// Extracts validation errors from API response data.
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
