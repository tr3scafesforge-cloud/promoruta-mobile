import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/payments/domain/models/mercado_pago_oauth_models.dart';

abstract class MercadoPagoOAuthRemoteDataSource {
  Future<MercadoPagoAuthorizeUrlData> getAuthorizeUrl();
  Future<MercadoPagoAccountStatus> getStatus();
  Future<void> disconnect();
}

class MercadoPagoOAuthRemoteDataSourceImpl
    implements MercadoPagoOAuthRemoteDataSource {
  final Dio dio;

  MercadoPagoOAuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<MercadoPagoAuthorizeUrlData> getAuthorizeUrl() async {
    try {
      final response = await dio.get(
        '/me/payments/mercadopago/oauth/authorize-url',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MercadoPagoAuthorizeUrlData.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to get Mercado Pago authorize URL.');
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Get Mercado Pago authorize URL failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');
      _throwFromDio(e);
    }
  }

  @override
  Future<MercadoPagoAccountStatus> getStatus() async {
    try {
      final response = await dio.get(
        '/me/payments/mercadopago/oauth/status',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MercadoPagoAccountStatus.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to get Mercado Pago status.');
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Get Mercado Pago status failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');
      _throwFromDio(e);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      final response = await dio.delete(
        '/me/payments/mercadopago/oauth/disconnect',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return;
      }

      throw Exception('Failed to disconnect Mercado Pago account.');
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Disconnect Mercado Pago failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');
      _throwFromDio(e);
    }
  }

  Never _throwFromDio(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        throw Exception(message.trim());
      }
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw Exception('Network error. Please check your connection.');
    }

    throw Exception('Mercado Pago request failed.');
  }
}
