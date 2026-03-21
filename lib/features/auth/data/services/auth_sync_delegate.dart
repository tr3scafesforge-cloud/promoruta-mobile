import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/contracts/auth_session_store.dart';
import 'package:promoruta/shared/services/sync_domain_delegate.dart';

class AuthSyncDelegate implements SyncDomainDelegate {
  final AuthSessionStore _authLocalDataSource;

  AuthSyncDelegate(this._authLocalDataSource);

  @override
  Future<void> sync() async {
    final user = await _authLocalDataSource.getUser();
    if (user != null && user.accessToken != null) {
      final now = DateTime.now();
      if (user.tokenExpiry != null &&
          user.tokenExpiry!.isBefore(now.add(Duration(minutes: 5)))) {
        AppLogger.sync.i('Token expires soon, consider refreshing');
      }
    }
  }

  @override
  Future<bool> hasPendingChanges() async => false;
}
