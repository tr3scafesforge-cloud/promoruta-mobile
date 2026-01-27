import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../shared/constants/map_constants.dart';
import '../../../../shared/models/route_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../location/location.dart';

class MapScreen extends ConsumerStatefulWidget {
  final List<LatLng>? waypoints;
  final bool showRoute;

  const MapScreen({
    super.key,
    this.waypoints,
    this.showRoute = false,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _mapboxMap;
  LatLng? _currentLocation;
  RouteModel? _currentRoute;
  bool _isLoadingRoute = false;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  StreamSubscription<LatLng>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final location = await locationService.getCurrentLocation();

    if (location != null && mounted) {
      setState(() {
        _currentLocation = location;
      });

      // Start tracking location updates
      locationService.startTracking();
      _locationSubscription =
          locationService.locationStream.listen((newLocation) {
        if (mounted) {
          setState(() {
            _currentLocation = newLocation;
          });
          _updateUserLocationMarker(newLocation);
        }
      });

      // Load route if waypoints are provided
      if (widget.showRoute &&
          widget.waypoints != null &&
          widget.waypoints!.isNotEmpty) {
        _loadRoute();
      }
    }
  }

  Future<void> _loadRoute() async {
    if (_currentLocation == null ||
        widget.waypoints == null ||
        widget.waypoints!.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final routeService = ref.read(routeServiceProvider);

      // If there's only one waypoint, calculate route to it
      if (widget.waypoints!.length == 1) {
        final route = await routeService.getRoute(
          origin: _currentLocation!,
          destination: widget.waypoints!.first,
          profile: 'driving',
        );

        if (route != null && mounted) {
          setState(() {
            _currentRoute = route;
          });
          _drawRoute(route);
        }
      } else {
        // Multiple waypoints - optimize route
        final route = await routeService.optimizeRoute(
          waypoints: widget.waypoints!,
          origin: _currentLocation,
          profile: 'driving',
        );

        if (route != null && mounted) {
          setState(() {
            _currentRoute = route;
          });
          _drawRoute(route);
        }
      }
    } catch (e) {
      debugPrint('Error loading route: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  Future<void> _drawRoute(RouteModel route) async {
    if (_polylineAnnotationManager == null) return;

    // Clear existing routes
    await _polylineAnnotationManager!.deleteAll();

    // Convert LatLng to Position for Mapbox LineString
    final List<Position> positions = route.coordinates
        .map((coord) => Position(coord.longitude, coord.latitude))
        .toList();

    // Create polyline annotation
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: MapConstants.routeColorPrimary,
      lineWidth: 5.0,
    );

    await _polylineAnnotationManager!.create(polylineOptions);

    // Fit bounds to show entire route
    if (route.coordinates.length >= 2) {
      final bounds = _calculateBounds(route.coordinates);
      _mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              (bounds['west']! + bounds['east']!) / 2,
              (bounds['south']! + bounds['north']!) / 2,
            ),
          ),
          zoom: 12.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  Map<String, double> _calculateBounds(List<LatLng> coordinates) {
    double north = coordinates.first.latitude;
    double south = coordinates.first.latitude;
    double east = coordinates.first.longitude;
    double west = coordinates.first.longitude;

    for (final coord in coordinates) {
      if (coord.latitude > north) north = coord.latitude;
      if (coord.latitude < south) south = coord.latitude;
      if (coord.longitude > east) east = coord.longitude;
      if (coord.longitude < west) west = coord.longitude;
    }

    return {'north': north, 'south': south, 'east': east, 'west': west};
  }

  Future<void> _updateUserLocationMarker(LatLng location) async {
    if (_pointAnnotationManager == null) return;

    // Clear existing markers
    await _pointAnnotationManager!.deleteAll();

    // Add user location marker
    final pointOptions = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(location.longitude, location.latitude),
      ),
      iconSize: 1.5,
      textField: '📍',
      textSize: 16.0,
    );

    await _pointAnnotationManager!.create(pointOptions);
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Set initial camera position
    if (_currentLocation != null) {
      mapboxMap.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _currentLocation!.longitude,
              _currentLocation!.latitude,
            ),
          ),
          zoom: MapConstants.defaultZoom,
        ),
      );
    }

    // Initialize annotation managers
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    // Add current location marker
    if (_currentLocation != null) {
      _updateUserLocationMarker(_currentLocation!);
    }
  }

  @override
  void dispose() {
    // Cancel the location subscription
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          if (_isLoadingRoute)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null && _mapboxMap != null) {
                _mapboxMap!.flyTo(
                  CameraOptions(
                    center: Point(
                      coordinates: Position(
                        _currentLocation!.longitude,
                        _currentLocation!.latitude,
                      ),
                    ),
                    zoom: MapConstants.defaultZoom,
                  ),
                  MapAnimationOptions(duration: 500),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: CameraOptions(
              center: _currentLocation != null
                  ? Point(
                      coordinates: Position(
                        _currentLocation!.longitude,
                        _currentLocation!.latitude,
                      ),
                    )
                  : Point(coordinates: Position(0, 0)),
              zoom: MapConstants.defaultZoom,
            ),
            styleUri: MapConstants.streetStyle,
            onMapCreated: _onMapCreated,
          ),
          if (_currentRoute != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distance',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${_currentRoute!.distanceKm.toStringAsFixed(1)} km',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(_currentRoute!.duration),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
