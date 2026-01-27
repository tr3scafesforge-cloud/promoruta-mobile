import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Test page for point annotations (markers)
class PointAnnotationTest extends StatefulWidget {
  const PointAnnotationTest({super.key});

  @override
  State<PointAnnotationTest> createState() => _PointAnnotationTestState();
}

class _PointAnnotationTestState extends State<PointAnnotationTest> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create point annotation manager
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Add a marker at Bogotá center
    _addMarker(Position(-74.0721, 4.7110), 'Bogotá Center');

    // Add more test markers
    _addMarker(Position(-74.0836, 4.6533), 'South Point');
    _addMarker(Position(-74.0547, 4.6870), 'East Point');
  }

  Future<void> _addMarker(Position position, String text) async {
    if (_pointAnnotationManager == null) return;

    final pointOptions = PointAnnotationOptions(
      geometry: Point(coordinates: position),
      textField: text,
      textSize: 12.0,
      iconSize: 1.5,
    );

    await _pointAnnotationManager!.create(pointOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point Annotation Test'),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(-74.0721, 4.7110)), // Bogotá
          zoom: 12.0,
        ),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
