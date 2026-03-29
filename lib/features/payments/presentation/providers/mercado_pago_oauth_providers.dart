import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/features/payments/data/datasources/remote/mercado_pago_oauth_remote_data_source.dart';
import 'package:promoruta/features/payments/data/repositories/mercado_pago_oauth_repository_impl.dart';
import 'package:promoruta/features/payments/domain/models/mercado_pago_oauth_models.dart';
import 'package:promoruta/features/payments/domain/repositories/mercado_pago_oauth_repository.dart';
import 'package:promoruta/features/payments/domain/use_cases/mercado_pago_oauth_use_cases.dart';
import 'package:promoruta/shared/providers/infrastructure_providers.dart';

final mercadoPagoOAuthRemoteDataSourceProvider =
    Provider<MercadoPagoOAuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MercadoPagoOAuthRemoteDataSourceImpl(dio: dio);
});

final mercadoPagoOAuthRepositoryProvider = Provider<MercadoPagoOAuthRepository>(
  (ref) {
    final remoteDataSource =
        ref.watch(mercadoPagoOAuthRemoteDataSourceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    return MercadoPagoOAuthRepositoryImpl(
        remoteDataSource, connectivityService);
  },
);

final getMercadoPagoAuthorizeUrlUseCaseProvider =
    Provider<GetMercadoPagoAuthorizeUrlUseCase>((ref) {
  final repository = ref.watch(mercadoPagoOAuthRepositoryProvider);
  return GetMercadoPagoAuthorizeUrlUseCase(repository);
});

final getMercadoPagoStatusUseCaseProvider =
    Provider<GetMercadoPagoStatusUseCase>((ref) {
  final repository = ref.watch(mercadoPagoOAuthRepositoryProvider);
  return GetMercadoPagoStatusUseCase(repository);
});

final disconnectMercadoPagoUseCaseProvider =
    Provider<DisconnectMercadoPagoUseCase>((ref) {
  final repository = ref.watch(mercadoPagoOAuthRepositoryProvider);
  return DisconnectMercadoPagoUseCase(repository);
});

final mercadoPagoAccountStatusProvider =
    FutureProvider.autoDispose<MercadoPagoAccountStatus>((ref) async {
  final useCase = ref.watch(getMercadoPagoStatusUseCaseProvider);
  return useCase();
});
