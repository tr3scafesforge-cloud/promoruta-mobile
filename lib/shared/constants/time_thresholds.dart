/// Time-related thresholds and intervals used throughout the application.
class TimeThresholds {
  /// Polling interval for live campaign data refresh
  static const Duration pollingInterval = Duration(seconds: 10);

  /// Duration after which location data is considered stale
  static const Duration staleDataThreshold = Duration(minutes: 2);

  /// Duration after which a promoter is considered to have no signal
  static const Duration noSignalThreshold = Duration(minutes: 5);

  /// Signal strength thresholds based on time since last update (in minutes)
  /// Returns signal strength 0-4 based on how old the location data is
  static const int signalLevel4MaxMinutes = 1; // <1 min = full signal (4)
  static const int signalLevel3MaxMinutes = 2; // 1-2 min = good signal (3)
  static const int signalLevel2MaxMinutes = 3; // 2-3 min = fair signal (2)
  static const int signalLevel1MaxMinutes = 5; // 3-5 min = weak signal (1)
  // >5 min = no signal (0)

  /// Timeout for API requests
  static const Duration apiRequestTimeout = Duration(seconds: 30);

  /// Timeout for token refresh operations
  static const Duration tokenRefreshTimeout = Duration(seconds: 30);

  /// Retry delays for exponential backoff
  static const Duration retryDelayBase = Duration(seconds: 1);
  static const Duration retryDelayMax = Duration(seconds: 8);
  static const int maxRetryAttempts = 4;
}
