import 'package:promoruta/core/models/user.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/registration_models.dart';

/// Use case for user registration.
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Registers a new user with the provided information.
  /// Returns [RegistrationResponse] on success.
  /// Throws exception with error message on failure.
  Future<RegistrationResponse> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) async {
    // Client-side validation
    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }

    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Enter a valid email address');
    }

    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    if (password != passwordConfirmation) {
      throw Exception('Passwords do not match');
    }

    return await _repository.register(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role.toStringValue(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Use case for email verification.
class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  /// Verifies the user's email with the provided code.
  /// Returns [User] on success (user is now logged in).
  /// Throws exception with error message on failure.
  Future<User> call({
    required String email,
    required String code,
  }) async {
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    if (code.trim().isEmpty) {
      throw Exception('Verification code is required');
    }

    return await _repository.verifyEmail(
      email: email.trim().toLowerCase(),
      code: code.trim(),
    );
  }
}

/// Use case for resending verification code.
class ResendVerificationCodeUseCase {
  final AuthRepository _repository;

  ResendVerificationCodeUseCase(this._repository);

  /// Resends the verification code to the user's email.
  /// Returns success message on success.
  /// Throws exception with error message on failure.
  Future<String> call(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    return await _repository.resendVerificationCode(email.trim().toLowerCase());
  }
}
