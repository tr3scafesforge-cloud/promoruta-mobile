# Tasks: Implement Map Layer Selection

## 1. State Management
- [x] 1.1 Create `MapStyle` enum with values: `streets`, `satellite`, `outdoors`
- [x] 1.2 Create `map_style_provider.dart` with a Riverpod provider that reads/writes the selected style to shared preferences
- [x] 1.3 Add localization keys for map style names (Streets, Satellite, Outdoors)

## 2. UI Components
- [x] 2.1 Create `MapStylePicker` widget (bottom sheet with radio list of styles)
- [x] 2.2 Add preview icons for each map style option

## 3. Integration
- [x] 3.1 Update `advertiser_live_map_page.dart` to use the map style provider
- [x] 3.2 Wire up the "Layers" button to show the `MapStylePicker` bottom sheet
- [x] 3.3 Update `MapWidget` to use dynamic `styleUri` from provider
- [x] 3.4 Apply same pattern to `advertiser_live_page.dart` (both copies)
  - N/A: These are placeholder pages with fake maps (`_MapFullscreenPlaceholder`), not real Mapbox integration

## 4. Validation
- [ ] 4.1 Verify style changes apply immediately without map recreation
- [ ] 4.2 Verify preference persists across app restarts
- [ ] 4.3 Test on both Android and iOS
