# Mapbox Integration Test Pages

This directory contains test pages for verifying the Mapbox integration. These tests are based on the official [Mapbox Flutter SDK examples](https://github.com/mapbox/mapbox-maps-flutter/tree/main/example).

## Test Pages

### 1. Simple Map Test (`simple_map_test.dart`)
**Purpose**: Verify basic Mapbox map rendering
**What it tests**:
- MapWidget initialization
- Map creation callback
- Basic camera positioning
- Default map style (Streets)

**Expected Result**: A map centered on Bogotá should appear with street tiles.

---

### 2. Point Annotation Test (`point_annotation_test.dart`)
**Purpose**: Test adding markers/pins to the map
**What it tests**:
- Creating PointAnnotationManager
- Adding individual point annotations
- Setting text labels on markers
- Icon sizing

**Expected Result**: Three markers should appear on the map with labels:
- "Bogotá Center"
- "South Point"
- "East Point"

---

### 3. Polyline Test (`polyline_test.dart`)
**Purpose**: Test drawing lines/routes on the map
**What it tests**:
- Creating PolylineAnnotationManager
- Drawing lines with multiple coordinates
- Line styling (color, width)

**Expected Result**: A blue line should be drawn through Bogotá showing a route path.

---

### 4. Full Map Screen (`map_screen.dart`)
**Purpose**: Complete integration with location services
**What it tests**:
- Real-time GPS location tracking
- User location marker
- Location permissions
- Camera following user location

**Expected Result**:
- App requests location permission
- Map shows user's current location
- Red pin marker on user location
- "My Location" button works

---

### 5. Route to Single Destination
**Purpose**: Test routing to one destination
**What it tests**:
- RouteService integration
- Calculating route from current location
- Drawing route on map
- Route info card (distance, duration)

**Expected Result**:
- Route drawn from current location to Plaza de Bolívar
- Bottom card shows distance and duration
- Camera adjusts to show full route

---

### 6. Multi-Waypoint Route
**Purpose**: Test route optimization with multiple stops
**What it tests**:
- Route optimization algorithm
- Multiple waypoint handling
- Complex route rendering

**Expected Result**:
- Optimized route through all three points
- Route drawn on map
- Distance and duration displayed

---

## How to Access Tests

1. Run the app
2. Navigate to the User Profile page
3. Scroll down to "🧪 MAPBOX TEST FEATURES" section
4. Tap any test button

## Troubleshooting

### Map doesn't appear
- Check that `MAPBOX_ACCESS_TOKEN` is set in `.env` file
- Verify internet connection
- Check console for errors

### Location tests fail
- Grant location permissions when prompted
- Ensure GPS is enabled on device
- Test on physical device (emulator GPS may not work properly)

### Routes don't draw
- Check internet connection (API calls required)
- Verify Mapbox token has routing permissions
- Check API quota limits in Mapbox dashboard
- Look for fallback to OSRM in console logs

## Clean Up

After testing is complete, remove:
1. The test condition in `user_profile_page.dart` (line 154: `if (true)`)
2. These test files (or move to a dedicated test folder)
3. The import statements for test pages

## References

- [Mapbox Flutter SDK](https://docs.mapbox.com/flutter/maps/guides/)
- [Official Examples](https://github.com/mapbox/mapbox-maps-flutter/tree/main/example)
- [API Documentation](https://docs.mapbox.com/api/)
