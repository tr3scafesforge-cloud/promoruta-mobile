import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available map styles
enum MapStyle {
  streets,
  satellite,
  outdoors;

  String get styleUri {
    switch (this) {
      case MapStyle.streets:
        return MapboxStyles.MAPBOX_STREETS;
      case MapStyle.satellite:
        return MapboxStyles.SATELLITE_STREETS;
      case MapStyle.outdoors:
        return MapboxStyles.OUTDOORS;
    }
  }
}

/// Notifier for managing map style preference
class MapStyleNotifier extends StateNotifier<MapStyle> {
  static const _prefsKey = 'mapStyle';

  MapStyleNotifier() : super(MapStyle.streets) {
    _loadStyle();
  }

  Future<void> _loadStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final styleString = prefs.getString(_prefsKey);
    if (styleString != null) {
      state = MapStyle.values.firstWhere(
        (style) => style.name == styleString,
        orElse: () => MapStyle.streets,
      );
    }
  }

  Future<void> setStyle(MapStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, style.name);
  }
}

/// Provider for map style preference
final mapStyleProvider =
    StateNotifierProvider<MapStyleNotifier, MapStyle>((ref) {
  return MapStyleNotifier();
});
