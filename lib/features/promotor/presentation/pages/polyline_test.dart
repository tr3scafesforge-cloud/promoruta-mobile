import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Test page for drawing polylines (routes)
class PolylineTest extends StatefulWidget {
  const PolylineTest({super.key});

  @override
  State<PolylineTest> createState() => _PolylineTestState();
}

class _PolylineTestState extends State<PolylineTest> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineAnnotationManager;

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create polyline annotation manager
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    // Draw a test route in Bogotá
    _drawTestRoute();
  }

  Future<void> _drawTestRoute() async {
    if (_polylineAnnotationManager == null) return;

    // Create a simple route through Bogotá
    final coordinates = [
      Position(-74.0721, 4.7110), // Start
      Position(-74.0700, 4.7000), // Point 1
      Position(-74.0600, 4.6950), // Point 2
      Position(-74.0500, 4.6900), // Point 3
      Position(-74.0400, 4.6850), // End
    ];

    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: coordinates),
      lineColor: Colors.blue.toARGB32(),
      lineWidth: 5.0,
    );

    await _polylineAnnotationManager!.create(polylineOptions);

    debugPrint('Route drawn successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polyline Test'),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center:
              Point(coordinates: Position(-74.0560, 4.6975)), // Center of route
          zoom: 12.0,
        ),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
