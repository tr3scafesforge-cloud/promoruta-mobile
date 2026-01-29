# Change: Set Default Locale to Spanish and Hide Language Selector

## Why
The app currently defaults to English and exposes a language selector in both the advertiser and promoter profile pages. Since the initial market is Uruguay, the default language should be Spanish and the language switching UI should be hidden until multi-language support is needed for expansion.

## What Changes
- Change the default locale from English (`en`) to Spanish (`es`) in `LocaleNotifier`
- Remove the language settings tile from both the advertiser and promoter profile pages
- The language settings page and route remain in the codebase for future use; only the navigation entry points are removed

## Impact
- Affected specs: `user-registration` (Localization requirement)
- Affected code:
  - `lib/shared/providers/providers.dart` (LocaleNotifier default)
  - `lib/presentation/advertiser/pages/advertiser_profile_page.dart` (hide language tile)
  - `lib/presentation/promotor/pages/promoter_profile_page.dart` (hide language tile)
