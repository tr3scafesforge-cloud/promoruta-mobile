import 'package:promoruta/core/models/user.dart';

/// Request model for user registration.
class RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;

  const RegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
  }
}

/// Response model for successful registration.
class RegistrationResponse {
  final String message;
  final bool requiresVerification;
  final String? email;

  const RegistrationResponse({
    required this.message,
    required this.requiresVerification,
    this.email,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      message: json['message'] as String? ?? 'Registration successful',
      requiresVerification: json['requires_verification'] as bool? ?? true,
      email: json['email'] as String?,
    );
  }
}

/// Request model for email verification.
class VerifyEmailRequest {
  final String email;
  final String code;

  const VerifyEmailRequest({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

/// Response model for successful email verification.
/// Returns user data and tokens, similar to login response.
class VerifyEmailResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int? refreshExpiresIn;

  const VerifyEmailResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.refreshExpiresIn,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    final expiresIn = json['expires_in'] as int;
    final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    final refreshExpiresInSeconds = json['refresh_expires_in'] as int?;
    final refreshExpiresIn = refreshExpiresInSeconds != null
        ? DateTime.now().add(Duration(seconds: refreshExpiresInSeconds))
        : null;

    return VerifyEmailResponse(
      user: User(
        id: userData['id'].toString(),
        name: userData['name'] as String,
        email: userData['email'] as String,
        emailVerifiedAt: userData['email_verified_at'] != null
            ? DateTime.parse(userData['email_verified_at'] as String)
            : DateTime.now(),
        role: UserRole.fromString(userData['role'] as String),
        createdAt: userData['created_at'] != null
            ? DateTime.parse(userData['created_at'] as String)
            : null,
        updatedAt: userData['updated_at'] != null
            ? DateTime.parse(userData['updated_at'] as String)
            : null,
        accessToken: json['access_token'] as String,
        tokenExpiry: tokenExpiry,
        refreshToken: json['refresh_token'] as String,
        refreshExpiresIn: refreshExpiresIn,
        username: userData['name'] as String,
        twoFactorEnabled: userData['two_factor_enabled'] as bool? ?? false,
        twoFactorConfirmedAt: userData['two_factor_confirmed_at'] != null
            ? DateTime.parse(userData['two_factor_confirmed_at'] as String)
            : null,
      ),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: expiresIn,
      refreshExpiresIn: refreshExpiresInSeconds,
    );
  }
}

/// Response model for resend verification code.
class ResendVerificationResponse {
  final String message;

  const ResendVerificationResponse({
    required this.message,
  });

  factory ResendVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ResendVerificationResponse(
      message: json['message'] as String? ?? 'Verification code sent',
    );
  }
}
