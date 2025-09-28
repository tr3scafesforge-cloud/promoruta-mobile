/// Abstract service for synchronizing local data with remote server.
/// Handles uploading local changes and downloading updates when online.
abstract class SyncService {
  /// Starts the synchronization process.
  /// Should be called when connectivity is restored.
  Future<void> sync();

  /// Checks if there are pending changes to sync.
  Future<bool> hasPendingChanges();

  /// Manually triggers sync for a specific domain or data type.
  /// [domain] could be 'auth', 'campaigns', 'gps', etc.
  Future<void> syncDomain(String domain);
}