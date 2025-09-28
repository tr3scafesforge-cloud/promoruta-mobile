import 'dart:async';

/// Abstract service for monitoring network connectivity status.
/// Implementations should provide real-time connectivity updates.
abstract class ConnectivityService {
  /// Stream of connectivity status changes.
  /// Emits true when online, false when offline.
  Stream<bool> get connectivityStream;

  /// Current connectivity status.
  /// Returns true if online, false if offline.
  Future<bool> get isConnected;

  /// Dispose of any resources used by the service.
  void dispose();
}