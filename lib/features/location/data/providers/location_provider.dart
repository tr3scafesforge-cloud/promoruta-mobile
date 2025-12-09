import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/providers.dart';
import '../../domain/location_service.dart';
import '../services/location_service_impl.dart';

/// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  final logger = ref.watch(loggerProvider);
  return LocationServiceImpl(logger: logger);
});
