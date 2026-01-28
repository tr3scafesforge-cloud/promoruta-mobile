# Change: Implement Map Layer Selection

## Why
The advertiser live map page has a "Layers" button that currently does nothing (TODO at line 251). The `advertiser-live-view` spec already defines this requirement: users should be able to toggle between satellite, terrain, and standard map views.

## What Changes
- Add a map style provider to manage the current map style preference
- Implement a bottom sheet modal for layer selection when the "Layers" button is tapped
- Support switching between Streets, Satellite, and Outdoors map styles (already defined in `MapConstants`)
- Persist the user's preference using shared preferences
- Apply the feature consistently across all map pages with layer buttons

## Impact
- Affected specs: `advertiser-live-view` (existing scenario being implemented)
- Affected code:
  - `lib/features/advertiser/campaign_management/presentation/pages/advertiser_live_map_page.dart`
  - `lib/features/advertiser/campaign_management/presentation/pages/advertiser_live_page.dart`
  - `lib/presentation/advertiser/pages/advertiser_live_page.dart`
  - New: `lib/shared/providers/map_style_provider.dart`
  - New: `lib/shared/widgets/map_style_picker.dart`
