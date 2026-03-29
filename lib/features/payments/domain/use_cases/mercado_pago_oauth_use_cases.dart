import 'package:promoruta/features/payments/domain/models/mercado_pago_oauth_models.dart';
import 'package:promoruta/features/payments/domain/repositories/mercado_pago_oauth_repository.dart';

class GetMercadoPagoAuthorizeUrlUseCase {
  final MercadoPagoOAuthRepository _repository;

  GetMercadoPagoAuthorizeUrlUseCase(this._repository);

  Future<MercadoPagoAuthorizeUrlData> call() {
    return _repository.getAuthorizeUrl();
  }
}

class GetMercadoPagoStatusUseCase {
  final MercadoPagoOAuthRepository _repository;

  GetMercadoPagoStatusUseCase(this._repository);

  Future<MercadoPagoAccountStatus> call() {
    return _repository.getStatus();
  }
}

class DisconnectMercadoPagoUseCase {
  final MercadoPagoOAuthRepository _repository;

  DisconnectMercadoPagoUseCase(this._repository);

  Future<void> call() {
    return _repository.disconnect();
  }
}
