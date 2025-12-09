import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:promoruta/core/constants/colors.dart';

import '../../../../../shared/constants/map_constants.dart';
import '../../../../../shared/models/route_model.dart';
import '../../../../../shared/providers/providers.dart';

/// Interactive map widget for selecting campaign coverage zone
/// User can tap to add multiple waypoints and see the actual driving route
class CoverageZoneMapPicker extends ConsumerStatefulWidget {
  final List<LatLng>? initialWaypoints;
  final LatLng initialCenter;
  final Function(List<LatLng> waypoints, RouteModel? route)? onRouteSelected;

  const CoverageZoneMapPicker({
    super.key,
    this.initialWaypoints,
    required this.initialCenter,
    this.onRouteSelected,
  });

  @override
  ConsumerState<CoverageZoneMapPicker> createState() => _CoverageZoneMapPickerState();
}

class _CoverageZoneMapPickerState extends ConsumerState<CoverageZoneMapPicker> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;

  final List<LatLng> _waypoints = [];
  RouteModel? _currentRoute;
  bool _isLoadingRoute = false;

  final List<PointAnnotation> _annotations = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialWaypoints != null) {
      _waypoints.addAll(widget.initialWaypoints!);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Initialize annotation managers
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    // Add existing waypoints if any
    if (_waypoints.isNotEmpty) {
      await _updateMarkers();
      if (_waypoints.length >= 2) {
        await _fetchAndDrawRoute();
      }
    }
  }

  void _onMapTap(MapContentGestureContext context) async {
    // Get the tapped geographic coordinate
    final position = context.point.coordinates;
    final tappedPoint = LatLng(position.lat.toDouble(), position.lng.toDouble());

    setState(() {
      // Add waypoint
      _waypoints.add(tappedPoint);
    });

    // Update markers
    await _updateMarkers();

    // If we have at least 2 points, calculate and draw route
    if (_waypoints.length >= 2) {
      await _fetchAndDrawRoute();
    }

    // Notify parent
    widget.onRouteSelected?.call(_waypoints, _currentRoute);
  }

  Future<void> _updateMarkers() async {
    if (_pointAnnotationManager == null) return;

    // Clear existing markers
    await _pointAnnotationManager!.deleteAll();
    _annotations.clear();

    // Add markers for each waypoint
    for (int i = 0; i < _waypoints.length; i++) {
      final point = _waypoints[i];
      final isFirst = i == 0;
      final isLast = i == _waypoints.length - 1;

      String label;
      int color;

      if (isFirst) {
        label = '🟢 Inicio';
        color = Colors.green.toARGB32();
      } else if (isLast) {
        label = '🔴 Fin';
        color = Colors.red.toARGB32();
      } else {
        label = '📍 Punto $i';
        color = Colors.blue.toARGB32();
      }

      final pointOptions = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(point.longitude, point.latitude),
        ),
        textField: label,
        textSize: 14.0,
        textColor: color,
        textOffset: [0.0, -2.0],
        iconSize: 1.5,
      );

      final annotation = await _pointAnnotationManager!.create(pointOptions);
      _annotations.add(annotation);
    }
  }

  Future<void> _fetchAndDrawRoute() async {
    if (_waypoints.length < 2) return;

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      // Get route service
      final routeService = ref.read(routeServiceProvider);

      RouteModel? route;

      // For 2 waypoints, use direct route
      if (_waypoints.length == 2) {
        route = await routeService.getRoute(
          origin: _waypoints.first,
          destination: _waypoints.last,
          profile: 'driving',
          alternatives: false,
        );
      } else {
        // For more waypoints, use optimization (if available)
        // Otherwise, just use first and last point
        route = await routeService.getRoute(
          origin: _waypoints.first,
          destination: _waypoints.last,
          profile: 'driving',
          alternatives: false,
        );
        // TODO: In the future, implement multi-waypoint routing
      }

      setState(() {
        _currentRoute = route;
        _isLoadingRoute = false;
      });

      // Draw the route on the map
      if (route != null) {
        await _drawRoute(route);
        // Fit bounds to show entire route
        _fitBoundsToRoute(route);
      }
    } catch (e) {
      setState(() {
        _isLoadingRoute = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al calcular la ruta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _drawRoute(RouteModel route) async {
    if (_polylineAnnotationManager == null) return;

    // Clear existing lines
    await _polylineAnnotationManager!.deleteAll();

    // Convert route coordinates to Position list
    final List<Position> positions = route.coordinates
        .map((coord) => Position(coord.longitude, coord.latitude))
        .toList();

    // Draw the route polyline
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: MapConstants.routeColorPrimary,
      lineWidth: 5.0,
    );

    await _polylineAnnotationManager!.create(polylineOptions);
  }

  void _fitBoundsToRoute(RouteModel route) {
    if (_mapboxMap == null || route.coordinates.isEmpty) return;

    // Calculate bounding box
    double minLat = route.coordinates.first.latitude;
    double maxLat = route.coordinates.first.latitude;
    double minLng = route.coordinates.first.longitude;
    double maxLng = route.coordinates.first.longitude;

    for (final coord in route.coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    // Calculate center
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    // Calculate appropriate zoom level (simplified)
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom = 13.0;
    if (maxDiff > 0.5) {
      zoom = 10.0;
    } else if (maxDiff > 0.2) {
      zoom = 11.5;
    } else if (maxDiff > 0.1) {
      zoom = 12.5;
    }

    _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(centerLng, centerLat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> _clearAnnotations() async {
    if (_pointAnnotationManager == null || _polylineAnnotationManager == null) {
      return;
    }

    await _pointAnnotationManager!.deleteAll();
    await _polylineAnnotationManager!.deleteAll();
    _annotations.clear();
  }

  void _resetRoute() {
    setState(() {
      _waypoints.clear();
      _currentRoute = null;
      _isLoadingRoute = false;
    });
    _clearAnnotations();

    // Reset camera to initial center
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            widget.initialCenter.longitude,
            widget.initialCenter.latitude,
          ),
        ),
        zoom: MapConstants.defaultZoom,
      ),
      MapAnimationOptions(duration: 500),
    );

    // Notify parent
    widget.onRouteSelected?.call([], null);
  }

  void _removeLastWaypoint() async {
    if (_waypoints.isEmpty) return;

    setState(() {
      _waypoints.removeLast();
    });

    await _updateMarkers();

    if (_waypoints.length >= 2) {
      await _fetchAndDrawRoute();
    } else {
      // Clear route if less than 2 waypoints
      await _polylineAnnotationManager?.deleteAll();
      setState(() {
        _currentRoute = null;
      });
    }

    // Notify parent
    widget.onRouteSelected?.call(_waypoints, _currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _waypoints.isEmpty
                      ? 'Toca en el mapa para añadir puntos de ruta (mínimo 2)'
                      : _waypoints.length == 1
                          ? 'Añade al menos un punto más para calcular la ruta'
                          : 'Ruta de ${_waypoints.length} puntos. Toca para añadir más.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Map
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayStroke),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              MapWidget(
                key: const ValueKey("coverageZoneMap"),
                cameraOptions: CameraOptions(
                  center: Point(
                    coordinates: Position(
                      widget.initialCenter.longitude,
                      widget.initialCenter.latitude,
                    ),
                  ),
                  zoom: MapConstants.defaultZoom,
                ),
                styleUri: MapConstants.streetStyle,
                onMapCreated: _onMapCreated,
                onTapListener: _onMapTap,
              ),

              // Loading indicator
              if (_isLoadingRoute)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),

              // Control buttons
              if (_waypoints.isNotEmpty)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      // Reset button
                      FloatingActionButton.small(
                        heroTag: 'reset',
                        backgroundColor: Colors.white,
                        onPressed: _resetRoute,
                        child: Icon(Icons.refresh, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 8),
                      // Undo last point button
                      FloatingActionButton.small(
                        heroTag: 'undo',
                        backgroundColor: Colors.white,
                        onPressed: _removeLastWaypoint,
                        child: Icon(Icons.undo, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Route info
        if (_waypoints.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grayStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route summary
                if (_currentRoute != null) ...[
                  Row(
                    children: [
                      Icon(Icons.route, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Distancia: ${_currentRoute!.distanceKm.toStringAsFixed(2)} km',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentRoute!.duration.inMinutes} min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppColors.grayStroke),
                  const SizedBox(height: 12),
                ],

                // Waypoints list
                Text(
                  'Puntos de ruta (${_waypoints.length}):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(_waypoints.length, (index) {
                  final point = _waypoints[index];
                  final isFirst = index == 0;
                  final isLast = index == _waypoints.length - 1;

                  Color dotColor;
                  String label;

                  if (isFirst) {
                    dotColor = Colors.green;
                    label = 'Inicio';
                  } else if (isLast) {
                    dotColor = Colors.red;
                    label = 'Fin';
                  } else {
                    dotColor = Colors.blue;
                    label = 'Punto $index';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$label: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
