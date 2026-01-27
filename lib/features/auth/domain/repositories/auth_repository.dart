import 'package:promoruta/core/core.dart';
import '../../data/models/registration_models.dart';
import '../models/two_factor_models.dart';

/// Abstract repository for authentication operations.
/// Handles login, logout, and user session management with offline support.
abstract class AuthRepository {
  /// Attempts to log in with email and password.
  /// Returns User if successful, throws exception if failed.
  Future<User> login(String email, String password);

  /// Refreshes the access token.
  Future<User> refreshToken(String accessToken);

  /// Checks if the current token is expired and refreshes it if needed.
  /// Returns the user with a valid token.
  Future<User?> ensureValidToken();

  /// Logs out the current user.
  Future<void> logout();

  /// Gets the current logged-in user, if any.
  Future<User?> getCurrentUser();

  /// Checks if user is logged in.
  Future<bool> isLoggedIn();

  /// Changes the user's password.
  Future<void> changePassword(String currentPassword, String newPassword,
      String newPasswordConfirmation);

  /// Requests a password reset code to be sent to the email.
  Future<String> requestPasswordResetCode(String email);

  /// Resets password using the verification code.
  Future<String> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });

  // Two-Factor Authentication methods

  /// Starts the process of enabling 2FA by generating a secret and QR code.
  Future<TwoFactorEnableResponse> enable2FA();

  /// Confirms and enables 2FA by verifying the code from the authenticator app.
  Future<TwoFactorConfirmResponse> confirm2FA(String secret, String code);

  /// Disables 2FA for the user (requires password confirmation).
  Future<String> disable2FA(String password);

  /// Verifies 2FA code during login.
  /// Returns User with tokens if successful.
  Future<User> verify2FACode({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  });

  /// Gets the current recovery codes.
  Future<RecoveryCodesResponse> getRecoveryCodes();

  /// Regenerates recovery codes (requires password confirmation).
  Future<RecoveryCodesResponse> regenerateRecoveryCodes(String password);

  // Registration methods

  /// Registers a new user.
  Future<RegistrationResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  });

  /// Verifies email with the verification code.
  Future<User> verifyEmail({
    required String email,
    required String code,
  });

  /// Resends the verification code to the email.
  Future<String> resendVerificationCode(String email);
}

/// Abstract local data source for authentication.
/// Handles caching user session locally.
abstract class AuthLocalDataSource {
  /// Saves user session locally.
  Future<void> saveUser(User user);

  /// Retrieves cached user, if any.
  Future<User?> getUser();

  /// Clears local user session.
  Future<void> clearUser();
}

/// Abstract remote data source for authentication.
/// Handles API calls for auth operations.
abstract class AuthRemoteDataSource {
  /// Logs in via API.
  Future<User> login(String email, String password);

  /// Registers a new user.
  Future<RegistrationResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  });

  /// Verifies email with the verification code.
  Future<VerifyEmailResponse> verifyEmail({
    required String email,
    required String code,
  });

  /// Resends the verification code to the email.
  Future<String> resendVerificationCode(String email);

  /// Refreshes the access token.
  Future<User> refreshToken(String accessToken);

  /// Logs out via API (if needed).
  Future<void> logout();

  /// Changes the user's password.
  Future<void> changePassword(String currentPassword, String newPassword,
      String newPasswordConfirmation);

  /// Requests a password reset code to be sent to the email.
  Future<String> requestPasswordResetCode(String email);

  /// Resets password using the verification code.
  Future<String> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });

  // Two-Factor Authentication methods

  /// Starts the process of enabling 2FA by generating a secret and QR code.
  Future<TwoFactorEnableResponse> enable2FA();

  /// Confirms and enables 2FA by verifying the code from the authenticator app.
  Future<TwoFactorConfirmResponse> confirm2FA(String secret, String code);

  /// Disables 2FA for the user (requires password confirmation).
  Future<String> disable2FA(String password);

  /// Verifies 2FA code during login.
  Future<User> verify2FACode({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  });

  /// Gets the current recovery codes.
  Future<RecoveryCodesResponse> getRecoveryCodes();

  /// Regenerates recovery codes (requires password confirmation).
  Future<RecoveryCodesResponse> regenerateRecoveryCodes(String password);
}
