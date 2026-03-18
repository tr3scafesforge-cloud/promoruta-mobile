/// Abstract delegate for domain-specific sync operations.
///
/// Each feature implements this interface to handle its own
/// sync logic, keeping the shared layer free of feature imports.
abstract class SyncDomainDelegate {
  /// Synchronizes this domain's data with the remote server.
  Future<void> sync();

  /// Returns true if there are local changes pending sync.
  Future<bool> hasPendingChanges();
}
