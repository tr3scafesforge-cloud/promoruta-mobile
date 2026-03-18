import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/services/connectivity_service.dart';
import 'package:promoruta/shared/services/sync_domain_delegate.dart';
import 'package:promoruta/shared/services/sync_service.dart';

class SyncServiceImpl implements SyncService {
  final ConnectivityService _connectivityService;
  final Map<String, SyncDomainDelegate> _delegates;

  SyncServiceImpl(this._connectivityService, this._delegates);

  @override
  Future<void> sync() async {
    if (!await _connectivityService.isConnected) {
      return;
    }

    try {
      for (final entry in _delegates.entries) {
        await entry.value.sync();
      }
    } catch (e) {
      AppLogger.sync.e('Sync failed: $e');
    }
  }

  @override
  Future<bool> hasPendingChanges() async {
    for (final delegate in _delegates.values) {
      if (await delegate.hasPendingChanges()) return true;
    }
    return false;
  }

  @override
  Future<void> syncDomain(String domain) async {
    if (!await _connectivityService.isConnected) {
      return;
    }

    final delegate = _delegates[domain];
    if (delegate == null) {
      throw UnsupportedError('Unknown domain: $domain');
    }

    await delegate.sync();
  }
}
