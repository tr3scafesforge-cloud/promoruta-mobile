// Location Provider (shared)
//
// Re-exports the location service provider for use across features.
// The implementation remains in the location feature module.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/providers/infrastructure_providers.dart';
import 'package:promoruta/features/location/domain/location_service.dart';
import 'package:promoruta/features/location/data/services/location_service_impl.dart';

// Re-export the interface for convenience
export 'package:promoruta/features/location/domain/location_service.dart';

/// Provider for location service
///
/// This provider is shared across features that need location functionality.
final locationServiceProvider = Provider<LocationService>((ref) {
  final logger = ref.watch(loggerProvider);
  return LocationServiceImpl(logger: logger);
});
