import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:promoruta/core/constants/colors.dart';

import '../../../../../shared/constants/map_constants.dart';

/// Interactive map widget for selecting campaign coverage zone
/// User can tap to set start and end points for the route
class CoverageZoneMapPicker extends StatefulWidget {
  final LatLng? startPoint;
  final LatLng? endPoint;
  final LatLng initialCenter;
  final Function(LatLng startPoint, LatLng endPoint)? onPointsSelected;

  const CoverageZoneMapPicker({
    super.key,
    this.startPoint,
    this.endPoint,
    required this.initialCenter,
    this.onPointsSelected,
  });

  @override
  State<CoverageZoneMapPicker> createState() => _CoverageZoneMapPickerState();
}

class _CoverageZoneMapPickerState extends State<CoverageZoneMapPicker> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;

  LatLng? _startPoint;
  LatLng? _endPoint;

  final List<PointAnnotation> _annotations = [];

  @override
  void initState() {
    super.initState();
    _startPoint = widget.startPoint;
    _endPoint = widget.endPoint;
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Initialize annotation managers
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    // Add existing points if any
    if (_startPoint != null) {
      await _addStartMarker(_startPoint!);
    }
    if (_endPoint != null) {
      await _addEndMarker(_endPoint!);
    }
    if (_startPoint != null && _endPoint != null) {
      await _drawLine();
    }
  }

  void _onMapTap(MapContentGestureContext context) {
    // Get the tapped geographic coordinate
    final position = context.point.coordinates;
    final tappedPoint = LatLng(position.lat.toDouble(), position.lng.toDouble());

    setState(() {
      if (_startPoint == null) {
        // First tap = start point
        _startPoint = tappedPoint;
        _addStartMarker(tappedPoint);
      } else if (_endPoint == null) {
        // Second tap = end point
        _endPoint = tappedPoint;
        _addEndMarker(tappedPoint);
        _drawLine();

        // Notify parent
        widget.onPointsSelected?.call(_startPoint!, _endPoint!);
      } else {
        // Reset and start over
        _startPoint = tappedPoint;
        _endPoint = null;
        _clearAnnotations();
        _addStartMarker(tappedPoint);
      }
    });
  }

  Future<void> _addStartMarker(LatLng point) async {
    if (_pointAnnotationManager == null) return;

    final pointOptions = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(point.longitude, point.latitude),
      ),
      textField: '🟢 Inicio',
      textSize: 14.0,
      textColor: Colors.green.toARGB32(),
      textOffset: [0.0, -2.0],
      iconSize: 1.5,
    );

    final annotation = await _pointAnnotationManager!.create(pointOptions);
    _annotations.add(annotation);
  }

  Future<void> _addEndMarker(LatLng point) async {
    if (_pointAnnotationManager == null) return;

    final pointOptions = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(point.longitude, point.latitude),
      ),
      textField: '🔴 Fin',
      textSize: 14.0,
      textColor: Colors.red.toARGB32(),
      textOffset: [0.0, -2.0],
      iconSize: 1.5,
    );

    final annotation = await _pointAnnotationManager!.create(pointOptions);
    _annotations.add(annotation);
  }

  Future<void> _drawLine() async {
    if (_polylineAnnotationManager == null ||
        _startPoint == null ||
        _endPoint == null) {
      return;
    }

    // Clear existing lines
    await _polylineAnnotationManager!.deleteAll();

    // Draw line between start and end
    final positions = [
      Position(_startPoint!.longitude, _startPoint!.latitude),
      Position(_endPoint!.longitude, _endPoint!.latitude),
    ];

    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: MapConstants.routeColorPrimary,
      lineWidth: 4.0,
    );

    await _polylineAnnotationManager!.create(polylineOptions);

    // Fit bounds to show both points
    _fitBoundsToPoints();
  }

  void _fitBoundsToPoints() {
    if (_mapboxMap == null || _startPoint == null || _endPoint == null) return;

    // Calculate center and zoom to fit both points
    final centerLat = (_startPoint!.latitude + _endPoint!.latitude) / 2;
    final centerLng = (_startPoint!.longitude + _endPoint!.longitude) / 2;

    _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(centerLng, centerLat)),
        zoom: 13.0,
      ),
      MapAnimationOptions(duration: 800),
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

  void _resetPoints() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
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
                  _startPoint == null
                      ? 'Toca en el mapa para marcar el punto de inicio'
                      : _endPoint == null
                          ? 'Toca nuevamente para marcar el punto final'
                          : 'Ruta seleccionada. Toca para cambiar.',
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

              // Reset button
              if (_startPoint != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    onPressed: _resetPoints,
                    child: Icon(Icons.refresh, color: AppColors.secondary),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Points info
        if (_startPoint != null || _endPoint != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grayStroke),
            ),
            child: Column(
              children: [
                if (_startPoint != null)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Inicio: ${_startPoint!.latitude.toStringAsFixed(4)}, ${_startPoint!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (_startPoint != null && _endPoint != null)
                  const SizedBox(height: 8),
                if (_endPoint != null)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fin: ${_endPoint!.latitude.toStringAsFixed(4)}, ${_endPoint!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
