import 'package:promoruta/core/core.dart';

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
  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation);
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

  /// Refreshes the access token.
  Future<User> refreshToken(String accessToken);

  /// Logs out via API (if needed).
  Future<void> logout();

  /// Changes the user's password.
  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation);
}
