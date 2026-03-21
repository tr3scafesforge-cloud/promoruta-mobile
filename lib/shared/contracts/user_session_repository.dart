import 'package:promoruta/core/core.dart';

/// Shared contract for services that need access to the current user session.
abstract class UserSessionRepository {
  Future<User?> getCurrentUser();

  Future<void> registerDeviceToken(String token);
}
