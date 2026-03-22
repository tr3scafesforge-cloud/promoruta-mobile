# Change: Resolve BuildContext async gap warnings

## Why

The analyzer currently reports `use_build_context_synchronously` warnings in authentication pages and push notification handling. These warnings indicate lifecycle-unsafe context usage after `await` boundaries and increase the risk of navigation or UI calls running against disposed widgets.

## What Changes

- Guard async UI flows before using `BuildContext` after awaited work
- Refactor push notification navigation/display code to avoid unsafe context access across async gaps
- Add focused verification to prevent the known warnings from regressing

## Impact

- **Affected specs:** `app-ui-safety`
- **Affected code:**
  - `lib/features/auth/presentation/pages/login_page.dart`
  - `lib/features/auth/presentation/pages/two_factor_login_page.dart`
  - `lib/features/auth/presentation/pages/verify_email_page.dart`
  - `lib/shared/services/push_notification_service.dart`
- **Breaking changes:** None
