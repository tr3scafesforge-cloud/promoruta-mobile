import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

import '../../../../shared/constants/map_constants.dart';
import '../../domain/location_service.dart';

class LocationServiceImpl implements LocationService {
  final Logger _logger;
  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<LatLng>.broadcast();

  LocationServiceImpl({required Logger logger}) : _logger = logger;

  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _logger.w('Location permission denied');
        return null;
      }

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        _logger.w('Location services are disabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      _logger.e('Error getting current location: $e');
      return null;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.w('Location permissions are permanently denied');
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Stream<LatLng> get locationStream => _locationController.stream;

  @override
  Future<void> startTracking() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _logger.w('Cannot start tracking: no location permission');
        return;
      }

      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: MapConstants.locationUpdateDistanceFilter.toInt(),
      );

      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
        (Position position) {
          _locationController.add(
            LatLng(position.latitude, position.longitude),
          );
        },
        onError: (error) {
          _logger.e('Error in location stream: $error');
        },
      );

      _logger.i('Location tracking started');
    } catch (e) {
      _logger.e('Error starting location tracking: $e');
    }
  }

  @override
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _logger.i('Location tracking stopped');
  }

  @override
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    _locationController.close();
  }
}
