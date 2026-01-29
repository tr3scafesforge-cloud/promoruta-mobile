# Tasks: Set Default Locale to Spanish and Hide Language Selector

## 1. Default Locale
- [ ] 1.1 Change `LocaleNotifier` default from `Locale('en')` to `Locale('es')` in `providers.dart`

## 2. Hide Language UI
- [ ] 2.1 Remove the language `ArrowTileCard` from `advertiser_profile_page.dart`
- [ ] 2.2 Remove the language `ArrowTileCard` from `promoter_profile_page.dart`
- [ ] 2.3 Remove the `onTapLanguage` callback parameter from both profile page widgets and their call sites

## 3. Validation
- [ ] 3.1 Run `flutter analyze` to confirm no compilation errors
