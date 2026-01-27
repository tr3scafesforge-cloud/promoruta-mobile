import 'package:promoruta/core/core.dart';
import 'package:promoruta/shared/use_cases/base_use_case.dart';
import '../models/two_factor_models.dart';
import '../repositories/auth_repository.dart';

/// Enable 2FA Use Case
/// Starts the process of enabling 2FA by generating a secret and QR code.
class Enable2FAUseCase implements UseCase<TwoFactorEnableResponse, NoParams> {
  final AuthRepository _repository;

  Enable2FAUseCase(this._repository);

  @override
  Future<TwoFactorEnableResponse> call(NoParams params) async {
    return await _repository.enable2FA();
  }
}

/// Confirm 2FA Use Case
/// Confirms and enables 2FA by verifying the code from the authenticator app.
class Confirm2FAUseCase
    implements UseCase<TwoFactorConfirmResponse, Confirm2FAParams> {
  final AuthRepository _repository;

  Confirm2FAUseCase(this._repository);

  @override
  Future<TwoFactorConfirmResponse> call(Confirm2FAParams params) async {
    return await _repository.confirm2FA(params.secret, params.code);
  }
}

class Confirm2FAParams {
  final String secret;
  final String code;

  Confirm2FAParams({required this.secret, required this.code});
}

/// Disable 2FA Use Case
/// Disables 2FA for the user (requires password confirmation).
class Disable2FAUseCase implements UseCase<String, Disable2FAParams> {
  final AuthRepository _repository;

  Disable2FAUseCase(this._repository);

  @override
  Future<String> call(Disable2FAParams params) async {
    return await _repository.disable2FA(params.password);
  }
}

class Disable2FAParams {
  final String password;

  Disable2FAParams({required this.password});
}

/// Verify 2FA Code Use Case
/// Verifies 2FA code during login.
class Verify2FACodeUseCase implements UseCase<User, Verify2FACodeParams> {
  final AuthRepository _repository;

  Verify2FACodeUseCase(this._repository);

  @override
  Future<User> call(Verify2FACodeParams params) async {
    return await _repository.verify2FACode(
      email: params.email,
      password: params.password,
      code: params.code,
      recoveryCode: params.recoveryCode,
    );
  }
}

class Verify2FACodeParams {
  final String email;
  final String password;
  final String? code;
  final String? recoveryCode;

  Verify2FACodeParams({
    required this.email,
    required this.password,
    this.code,
    this.recoveryCode,
  });
}

/// Get Recovery Codes Use Case
/// Gets the current recovery codes for the authenticated user.
class GetRecoveryCodesUseCase
    implements UseCase<RecoveryCodesResponse, NoParams> {
  final AuthRepository _repository;

  GetRecoveryCodesUseCase(this._repository);

  @override
  Future<RecoveryCodesResponse> call(NoParams params) async {
    return await _repository.getRecoveryCodes();
  }
}

/// Regenerate Recovery Codes Use Case
/// Regenerates recovery codes (requires password confirmation).
class RegenerateRecoveryCodesUseCase
    implements UseCase<RecoveryCodesResponse, RegenerateRecoveryCodesParams> {
  final AuthRepository _repository;

  RegenerateRecoveryCodesUseCase(this._repository);

  @override
  Future<RecoveryCodesResponse> call(
      RegenerateRecoveryCodesParams params) async {
    return await _repository.regenerateRecoveryCodes(params.password);
  }
}

class RegenerateRecoveryCodesParams {
  final String password;

  RegenerateRecoveryCodesParams({required this.password});
}

/// No parameters class for use cases that don't require parameters
class NoParams {}
