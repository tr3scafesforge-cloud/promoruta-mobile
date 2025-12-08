# Mapbox Integration Setup Guide

This guide explains how to set up and use Mapbox in the PromoRuta mobile application.

## Features

- **Interactive Maps**: Beautiful, customizable maps powered by Mapbox
- **Route Planning**: Calculate optimal routes with turn-by-turn directions
- **Route Optimization**: Optimize routes for multiple waypoints (TSP)
- **Offline Maps**: Download map tiles for offline use
- **Real-time Location**: Track user location in real-time
- **Free Tier**: 50,000 map loads + 100,000 routing requests/month FREE
- **OSRM Fallback**: Free alternative routing using OpenStreetMap data

## Setup Instructions

### 1. Install Dependencies

The following packages are already added to `pubspec.yaml`:

```yaml
dependencies:
  mapbox_maps_flutter: ^2.3.0
  geolocator: ^13.0.2
  latlong2: ^0.9.1
  flutter_dotenv: ^5.2.1
```

Run:
```bash
flutter pub get
```

### 2. Configure Mapbox Token

Your Mapbox access token is stored in the `.env` file:

```
MAPBOX_ACCESS_TOKEN=your_token_here
```

**Important**: Never commit the `.env` file to version control. It's already in `.gitignore`.

### 3. Platform-Specific Configuration

#### Android

Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION` - For precise location
- `ACCESS_COARSE_LOCATION` - For approximate location
- `ACCESS_BACKGROUND_LOCATION` - For background tracking (optional)

#### iOS

Location permissions are configured in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription` - For foreground location
- `NSLocationAlwaysAndWhenInUseUsageDescription` - For background location

### 4. Run the App

```bash
flutter run
```

## Usage

### Basic Map Screen

```dart
import 'package:promoruta/features/promotor/presentation/pages/map_screen.dart';

// Show basic map
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MapScreen(),
  ),
);
```

### Map with Route

```dart
import 'package:latlong2/latlong.dart';

// Show map with route to waypoints
final waypoints = [
  LatLng(37.7749, -122.4194), // San Francisco
  LatLng(37.8044, -122.2712), // Oakland
];

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MapScreen(
      waypoints: waypoints,
      showRoute: true,
    ),
  ),
);
```

### Get Current Location

```dart
final locationService = ref.read(locationServiceProvider);
final location = await locationService.getCurrentLocation();

if (location != null) {
  print('Lat: ${location.latitude}, Lng: ${location.longitude}');
}
```

### Calculate Route

```dart
final routeService = ref.read(routeServiceProvider);

final route = await routeService.getRoute(
  origin: LatLng(37.7749, -122.4194),
  destination: LatLng(37.8044, -122.2712),
  profile: 'driving', // or 'walking', 'cycling'
);

if (route != null) {
  print('Distance: ${route.distanceKm} km');
  print('Duration: ${route.duration.inMinutes} minutes');
}
```

### Optimize Multi-Stop Route

```dart
final waypoints = [
  LatLng(37.7749, -122.4194),
  LatLng(37.8044, -122.2712),
  LatLng(37.7849, -122.4094),
];

final route = await routeService.optimizeRoute(
  waypoints: waypoints,
  profile: 'driving',
);
```

### Track Location in Real-time

```dart
final locationService = ref.read(locationServiceProvider);

// Start tracking
await locationService.startTracking();

// Listen to updates
locationService.locationStream.listen((location) {
  print('New location: ${location.latitude}, ${location.longitude}');
});

// Stop tracking
await locationService.stopTracking();
```

## Services Architecture

### LocationService
- `getCurrentLocation()` - Get one-time location
- `startTracking()` - Start real-time tracking
- `stopTracking()` - Stop tracking
- `locationStream` - Stream of location updates
- `calculateDistance()` - Calculate distance between points

### RouteService
- `getRoute()` - Get route using Mapbox API
- `getRouteOsrm()` - Get route using free OSRM API
- `optimizeRoute()` - Optimize multi-waypoint route

### OfflineMapService (Planned)
- `downloadMapRegion()` - Download tiles for offline use
- `isRegionDownloaded()` - Check if region is cached
- `deleteRegion()` - Remove cached tiles

## API Costs & Limits

### Mapbox Free Tier (Monthly)
- 50,000 map loads
- 100,000 routing requests
- 50 GB tile requests

### OSRM (Free)
- Unlimited requests
- Self-hosted or public API
- No API key required

### Cost Management
The app automatically falls back to OSRM if:
- Mapbox API fails
- Rate limits exceeded
- No internet (uses cached routes)

## Customization

### Map Styles

Available in `lib/shared/constants/map_constants.dart`:

```dart
MapConstants.streetStyle       // Street map
MapConstants.satelliteStyle    // Satellite imagery
MapConstants.outdoorsStyle     // Outdoor/hiking style
```

### Route Colors

```dart
MapConstants.routeColorPrimary      // Primary route color
MapConstants.routeColorAlternative  // Alternative route color
```

### Location Settings

```dart
MapConstants.locationUpdateDistanceFilter  // Min distance for updates (meters)
MapConstants.locationUpdateInterval        // Update frequency
```

## Offline Maps (Coming Soon)

To enable offline maps:

1. Define the region to download
2. Download tiles at appropriate zoom levels
3. Cache locally for offline use

```dart
// Future implementation
await offlineMapService.downloadMapRegion(
  southwest: LatLng(37.7, -122.5),
  northeast: LatLng(37.9, -122.3),
  regionName: 'san_francisco',
  minZoom: 10.0,
  maxZoom: 16.0,
);
```

## Troubleshooting

### Location not updating
1. Check permissions are granted
2. Ensure location services are enabled on device
3. Check GPS signal (outdoor for best accuracy)

### Route calculation fails
- Check internet connection
- Verify Mapbox token is valid
- Check API quota limits
- Falls back to OSRM automatically

### Map not loading
- Verify Mapbox token in `.env`
- Check internet connection
- Ensure `.env` is loaded in `main.dart`

## Production Deployment

### Android
1. Ensure minSdkVersion >= 21 in `android/app/build.gradle`
2. Test location permissions flow
3. Configure ProGuard rules if using code shrinking

### iOS
1. Set location usage descriptions in Info.plist
2. Test on physical device (simulator has limited GPS)
3. Configure background modes if needed

### Best Practices
- Cache frequently used routes
- Implement offline mode with OSRM
- Monitor API usage in Mapbox dashboard
- Use appropriate map zoom levels to save quota
- Implement retry logic with exponential backoff

## Support

For Mapbox issues:
- Documentation: https://docs.mapbox.com/
- API Status: https://status.mapbox.com/

For OSRM:
- Documentation: http://project-osrm.org/
- GitHub: https://github.com/Project-OSRM/osrm-backend
