# Tasks: Set Default Theme to Light Mode and Hide Theme Selector

## 1. Default Theme
- [x] 1.1 Change `ThemeModeNotifier` default from `ThemeMode.system` to `ThemeMode.light` in `providers.dart`

## 2. Advertiser Profile Page
- [x] 2.1 Remove `isDarkMode` and `onToggleDarkMode` parameters from `AdvertiserProfilePage`
- [x] 2.2 Remove `_darkMode` state variable and related `initState` logic
- [x] 2.3 Remove the dark mode `SwitchTileCard` widget

## 3. Promoter Profile Page
- [x] 3.1 Remove `isDarkMode` and `onToggleDarkMode` parameters from `PromoterProfilePage`
- [x] 3.2 Remove `_darkMode` state variable and related `initState` logic
- [x] 3.3 Remove the dark mode `SwitchTileCard` widget

## 4. Home Screen Call Sites
- [x] 4.1 Remove `isDarkMode` and `onToggleDarkMode` arguments from `advertiser_home_screen.dart`
- [x] 4.2 Remove `isDarkMode` and `onToggleDarkMode` arguments from `promoter_home_screen.dart`
- [x] 4.3 Remove unused `providers.dart` import from `promoter_home_screen.dart`

## 5. Validation
- [x] 5.1 Run `flutter analyze` to confirm no compilation errors
