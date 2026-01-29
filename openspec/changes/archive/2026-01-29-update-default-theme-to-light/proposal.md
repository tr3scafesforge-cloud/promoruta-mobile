# Change: Set Default Theme to Light Mode and Hide Theme Selector

## Why
The app currently defaults to system theme and exposes a dark mode toggle in both the advertiser and promoter profile pages. For initial launch simplicity, the default theme should be light mode and the toggle should be hidden until dark mode is properly designed and tested.

## What Changes
- Change the default theme from `ThemeMode.system` to `ThemeMode.light` in `ThemeModeNotifier`
- Remove the dark mode `SwitchTileCard` from both the advertiser and promoter profile pages
- Remove the `isDarkMode` and `onToggleDarkMode` parameters from both profile page widgets
- Clean up related local state (`_darkMode`) from both profile pages

## Impact
- Affected specs: None (no existing spec for theme/appearance settings)
- Affected code:
  - `lib/shared/providers/providers.dart` (ThemeModeNotifier default)
  - `lib/presentation/advertiser/pages/advertiser_profile_page.dart` (remove toggle and params)
  - `lib/presentation/promotor/pages/promoter_profile_page.dart` (remove toggle and params)
  - `lib/features/advertiser/presentation/pages/advertiser_home_screen.dart` (remove callback)
  - `lib/features/promotor/presentation/pages/promoter_home_screen.dart` (remove callback)
