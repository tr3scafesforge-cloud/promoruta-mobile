# Mapbox SDK Investigation & Architecture Decision

## Question
Why do we use REST API calls (via Dio) for Mapbox routing instead of using an SDK like we do for map rendering (`mapbox_maps_flutter`)?

## Investigation

### Current Implementation
Our current routing service uses **manual HTTP calls** with Dio:
- Direct calls to `https://api.mapbox.com/directions/v5/`
- Manual JSON parsing
- Error-prone string concatenation for coordinates
- Inconsistent with map rendering approach

### Map Rendering (mapbox_maps_flutter)
For map display, we use the official **mapbox_maps_flutter SDK**:
- Clean widget API: `MapWidget`, `PointAnnotationManager`, etc.
- Type-safe operations
- Well-maintained by Mapbox
- Modern SDK (v2.3.0+)

### Attempted Solution: mapbox_api Package

We investigated the [`mapbox_api` package (v1.1.0)](https://pub.dev/packages/mapbox_api) as a potential SDK for routing.

**Issues Discovered:**
1. **Outdated Package** - Last published 14 months ago (October 2024)
2. **Type Incompatibility** - Returns custom objects that don't match current Mapbox API response structure
3. **No `toJson()` Methods** - Objects can't be easily converted back to JSON
4. **Limited Maintenance** - Community package, not official Mapbox
5. **Missing Type Exports** - `Route`, `Trip`, `Step`, `Waypoint` classes aren't properly exported
6. **Nullable API Issues** - `optimization` property is nullable, complicating usage

**Example Code Attempted:**
```dart
final _mapboxApi = MapboxApi(accessToken: token);

final response = await _mapboxApi.directions.request(
  profile: NavigationProfile.DRIVING_TRAFFIC,
  coordinates: coordinates,
  steps: true,
  geometries: NavigationGeometries.POLYLINE,
);

// Problem: response.routes returns NavigationRoute objects
// These don't have toJson() and can't be easily converted
```

## Architecture Decision

### ✅ Recommendation: Continue Using Current Approach

**Reasons:**
1. **Simplicity** - Direct HTTP calls are straightforward and transparent
2. **Reliability** - Works with current Mapbox Directions API (v5)
3. **Flexibility** - Easy to debug and customize
4. **Fallback Support** - Clean OSRM fallback already implemented
5. **No Additional Dependencies** - Uses Dio which is already in the project

### Current Implementation Benefits

```dart
// Clean, readable, maintainable
final url = '${MapConstants.mapboxDirectionsApiBase}/mapbox/$profile/$coordinates';

final response = await _dio.get(url, queryParameters: {
  'access_token': Env.mapboxAccessToken,
  'alternatives': alternatives,
  'geometries': 'polyline',
  'steps': true,
  'overview': 'full',
});

if (response.statusCode == 200) {
  return RouteModel.fromMapboxJson(response.data);
}
```

**What Makes This Good:**
- ✅ Direct API access
- ✅ Full control over requests
- ✅ Easy error handling
- ✅ JSON response is well-documented
- ✅ Works with latest Mapbox API
- ✅ Simple to test

### Consistency with Map Rendering

**Map Rendering (`mapbox_maps_flutter`):**
- Uses SDK for UI components (map display, annotations, polylines)
- These are complex UI elements that benefit from SDK abstraction

**Routing (current approach):**
- HTTP API calls for data fetching
- Similar to how we call other backend APIs
- Just happens to be Mapbox's backend instead of ours

This is actually **consistent** - we use SDKs for UI/rendering and HTTP clients for data fetching.

## Alternative: Official Mapbox Navigation SDK

If we need turn-by-turn navigation in the future, Mapbox offers:
- [Mapbox Navigation SDK for iOS](https://docs.mapbox.com/ios/navigation/)
- [Mapbox Navigation SDK for Android](https://docs.mapbox.com/android/navigation/)

However, these are native SDKs, not Flutter packages. Would require platform channels or wait for official Flutter support.

## Comparison Table

| Aspect | Current (Dio + REST) | mapbox_api Package | Official Navigation SDK |
|--------|---------------------|-------------------|------------------------|
| **Maintenance** | Self (simple) | Community (outdated) | Mapbox (native only) |
| **Type Safety** | Medium (JSON) | Low (compatibility issues) | High (native) |
| **Ease of Use** | High | Medium | N/A (no Flutter version) |
| **Reliability** | High | Medium | High |
| **Customization** | Full control | Limited | Limited |
| **API Version** | Latest (v5) | Older | Latest |
| **Dependencies** | Dio (existing) | +1 package | Platform channels |
| **Learning Curve** | Low | Medium | High |

## Conclusion

**The current approach using Dio for REST API calls is the best solution because:**

1. ✅ **It works reliably** with the latest Mapbox Directions API
2. ✅ **Simple and maintainable** - easy to understand and debug
3. ✅ **Consistent with data fetching patterns** across the app
4. ✅ **No additional dependencies** with compatibility issues
5. ✅ **Full control** over requests and error handling
6. ✅ **Easy OSRM fallback** already implemented

**The separation is actually good architecture:**
- **UI/Rendering Layer**: Use `mapbox_maps_flutter` SDK
  → MapWidget, PointAnnotations, PolylineAnnotations

- **Data Fetching Layer**: Use HTTP client (Dio)
  → Routing directions, optimization, geocoding

This follows the **separation of concerns** principle common in Flutter apps.

## Future Considerations

If Mapbox releases an official Flutter SDK for Navigation that includes:
- Turn-by-turn navigation UI
- Voice guidance
- Route deviation handling
- Offline routing

Then we should consider migrating. Until then, the current approach is optimal.

## References

- [Mapbox Directions API Documentation](https://docs.mapbox.com/api/navigation/directions/)
- [mapbox_maps_flutter Package](https://pub.dev/packages/mapbox_maps_flutter)
- [mapbox_api Package](https://pub.dev/packages/mapbox_api) (investigated but not recommended)
- [Flutter Dio HTTP Client](https://pub.dev/packages/dio)

---

**Decision Date**: December 2025
**Status**: ✅ Approved - Continue with current Dio-based approach
**Review Date**: Check for official Mapbox Flutter Navigation SDK in Q2 2026
