import 'package:promoruta/core/result.dart';
import 'package:promoruta/shared/shared.dart';

/// Use case for changing password
class ChangePasswordUseCase implements UseCaseResultVoid<ChangePasswordParams> {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  @override
  Future<Result<void>> call(ChangePasswordParams params) async {
    try {
      await _repository.changePassword(
        params.currentPassword,
        params.newPassword,
        params.newPasswordConfirmation,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
}

/// Parameters for change password use case
class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}