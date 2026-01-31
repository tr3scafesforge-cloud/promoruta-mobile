import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/shared/models/route_model.dart';
import '../widgets/coverage_zone_map_picker.dart';

/// Result data returned from the coverage zone map screen
class CoverageZoneMapResult {
  final List<LatLng> waypoints;
  final Map<int, String> waypointNames;
  final RouteModel? route;

  const CoverageZoneMapResult({
    required this.waypoints,
    required this.waypointNames,
    this.route,
  });
}

/// Full-screen map picker for selecting campaign coverage zone
class CoverageZoneMapScreen extends StatefulWidget {
  final LatLng initialCenter;
  final List<LatLng>? initialWaypoints;

  const CoverageZoneMapScreen({
    super.key,
    required this.initialCenter,
    this.initialWaypoints,
  });

  @override
  State<CoverageZoneMapScreen> createState() => _CoverageZoneMapScreenState();
}

class _CoverageZoneMapScreenState extends State<CoverageZoneMapScreen> {
  List<LatLng> _waypoints = [];
  Map<int, String> _waypointNames = {};
  RouteModel? _currentRoute;

  @override
  void initState() {
    super.initState();
    if (widget.initialWaypoints != null) {
      _waypoints = List.from(widget.initialWaypoints!);
    }
  }

  void _onRouteSelected(
    List<LatLng> waypoints,
    Map<int, String> waypointNames,
    RouteModel? route,
  ) {
    setState(() {
      _waypoints = waypoints;
      _waypointNames = waypointNames;
      _currentRoute = route;
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(CoverageZoneMapResult(
      waypoints: _waypoints,
      waypointNames: _waypointNames,
      route: _currentRoute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _waypoints.length >= 2;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Seleccionar zona de cobertura',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          if (canConfirm)
            TextButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.check, color: AppColors.secondary),
              label: Text(
                'Confirmar',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: CoverageZoneMapPicker(
          initialCenter: widget.initialCenter,
          initialWaypoints: widget.initialWaypoints,
          onRouteSelected: _onRouteSelected,
        ),
      ),
      bottomNavigationBar: canConfirm
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirmar ruta (${_waypoints.length} puntos)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
