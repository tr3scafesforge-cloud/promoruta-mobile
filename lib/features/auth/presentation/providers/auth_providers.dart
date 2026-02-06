// Auth Feature Providers
//
// This file defines auth-specific providers for the auth feature layer.
// Infrastructure providers (database, dio, connectivity) remain in shared.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:promoruta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:promoruta/features/auth/domain/models/two_factor_models.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';
import 'package:promoruta/features/auth/domain/use_cases/auth_use_cases.dart';
import 'package:promoruta/features/auth/domain/use_cases/two_factor_use_cases.dart';
import 'package:promoruta/features/auth/domain/use_cases/registration_use_cases.dart';
// Import infrastructure providers directly to avoid circular dependency
import 'package:promoruta/shared/providers/infrastructure_providers.dart';

// Re-export permission provider
export 'permission_provider.dart';

// Re-export authLocalDataSourceProvider from infrastructure
export 'package:promoruta/shared/providers/infrastructure_providers.dart'
    show authLocalDataSourceProvider;

// ============ Data Sources ============

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRemoteDataSourceImpl(dio: dio, localDataSource: localDataSource);
});

// ============ Repository ============

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return AuthRepositoryImpl(
    localDataSource,
    remoteDataSource,
    connectivityService,
  );
});

// ============ Use Cases ============

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(repository);
});

// 2FA Use Cases
final enable2FAUseCaseProvider = Provider<Enable2FAUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Enable2FAUseCase(repository);
});

final confirm2FAUseCaseProvider = Provider<Confirm2FAUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Confirm2FAUseCase(repository);
});

final disable2FAUseCaseProvider = Provider<Disable2FAUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Disable2FAUseCase(repository);
});

final verify2FACodeUseCaseProvider = Provider<Verify2FACodeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Verify2FACodeUseCase(repository);
});

final getRecoveryCodesUseCaseProvider =
    Provider<GetRecoveryCodesUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetRecoveryCodesUseCase(repository);
});

final regenerateRecoveryCodesUseCaseProvider =
    Provider<RegenerateRecoveryCodesUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegenerateRecoveryCodesUseCase(repository);
});

// Registration Use Cases
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyEmailUseCase(repository);
});

final resendVerificationCodeUseCaseProvider =
    Provider<ResendVerificationCodeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResendVerificationCodeUseCase(repository);
});

// ============ State Notifier ============

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<model.User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Auth state notifier that manages user authentication state.
class AuthNotifier extends StateNotifier<AsyncValue<model.User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } on TwoFactorRequiredException {
      // Reset state to data(null) when 2FA is required
      // so the UI can redirect to 2FA page
      if (mounted) {
        state = const AsyncValue.data(null);
      }
      rethrow;
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      if (mounted) {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Sets the authenticated user directly.
  /// Use this after email verification or 2FA login completes successfully.
  void setUser(model.User user) {
    if (mounted) {
      state = AsyncValue.data(user);
    }
  }
}
