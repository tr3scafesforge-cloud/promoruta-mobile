## 1. Implementation

- [x] 1.1 Create a new `CoverageZoneMapScreen` page that wraps `CoverageZoneMapPicker` in a `Scaffold`
- [x] 1.2 Add route definition for the new map screen in the app router (used Navigator.push instead for returning data)
- [x] 1.3 Update `CreateCampaignPage` to navigate to the map screen when the placeholder is tapped
- [x] 1.4 Pass initial waypoints to the map screen and receive selected waypoints/route on return
- [x] 1.5 Remove the inline `_showMap` toggle and embedded map display from `CreateCampaignPage`
- [x] 1.6 Update the placeholder to show selected route summary when waypoints exist
- [x] 1.7 Revert the GestureDetector changes from `CoverageZoneMapPicker` (no longer needed)
- [x] 1.8 Remove unused `onInteractionStarted`/`onInteractionEnded` callbacks
- [ ] 1.9 Test map panning, zooming, and waypoint selection on the new screen
- [ ] 1.10 Test navigation flow: form → map → form with preserved data
