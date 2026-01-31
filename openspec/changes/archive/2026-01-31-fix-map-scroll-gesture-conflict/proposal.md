# Change: Fix map scroll gesture conflict in create campaign page

## Why
When the user tries to pan, zoom, or interact with the map on the create campaign page, the parent `ListView` intercepts the gestures and scrolls the page instead. The embedded map approach creates unresolvable gesture conflicts that make the map unusable for route selection.

## What Changes
- Move the map picker to a dedicated full-screen page
- The "Seleccionar zona en el mapa" placeholder button will navigate to the new map screen
- The map screen will return the selected waypoints and route back to the create campaign page
- Remove the inline map display from the create campaign form

## Impact
- Affected specs: campaign-creation (new spec)
- Affected code:
  - `lib/features/advertiser/campaign_creation/presentation/pages/create_campaign_page.dart` - Remove inline map, add navigation to map screen
  - `lib/features/advertiser/campaign_creation/presentation/widgets/coverage_zone_map_picker.dart` - Convert to full-screen page or wrap in a new page widget
  - `lib/core/router/app_router.dart` - Add route for the new map picker screen (if using named routes)
