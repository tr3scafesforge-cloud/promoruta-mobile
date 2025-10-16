import 'package:promoruta/shared/shared.dart';

/// Use case for changing password
class ChangePasswordUseCase implements UseCaseVoid<ChangePasswordParams> {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  @override
  Future<void> call(ChangePasswordParams params) async {
    return await _repository.changePassword(
      params.currentPassword,
      params.newPassword,
      params.newPasswordConfirmation,
    );
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