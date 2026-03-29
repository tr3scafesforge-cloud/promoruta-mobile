import 'package:promoruta/features/payments/data/datasources/remote/mercado_pago_oauth_remote_data_source.dart';
import 'package:promoruta/features/payments/domain/models/mercado_pago_oauth_models.dart';
import 'package:promoruta/features/payments/domain/repositories/mercado_pago_oauth_repository.dart';
import 'package:promoruta/shared/services/connectivity_service.dart';

class MercadoPagoOAuthRepositoryImpl implements MercadoPagoOAuthRepository {
  final MercadoPagoOAuthRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  MercadoPagoOAuthRepositoryImpl(
    this._remoteDataSource,
    this._connectivityService,
  );

  @override
  Future<MercadoPagoAuthorizeUrlData> getAuthorizeUrl() async {
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    return _remoteDataSource.getAuthorizeUrl();
  }

  @override
  Future<MercadoPagoAccountStatus> getStatus() async {
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    return _remoteDataSource.getStatus();
  }

  @override
  Future<void> disconnect() async {
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    return _remoteDataSource.disconnect();
  }
}
