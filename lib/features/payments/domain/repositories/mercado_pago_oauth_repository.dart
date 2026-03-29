import 'package:promoruta/features/payments/domain/models/mercado_pago_oauth_models.dart';

abstract class MercadoPagoOAuthRepository {
  Future<MercadoPagoAuthorizeUrlData> getAuthorizeUrl();
  Future<MercadoPagoAccountStatus> getStatus();
  Future<void> disconnect();
}
