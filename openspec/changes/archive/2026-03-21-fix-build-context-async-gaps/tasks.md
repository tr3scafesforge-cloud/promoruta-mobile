## 1. Implementation
- [x] 1.1 Audit each `use_build_context_synchronously` warning and classify whether it needs a `mounted` guard, context capture removal, or navigation refactor
- [x] 1.2 Update `login_page.dart` to avoid using `BuildContext` after async gaps without lifecycle checks
- [x] 1.3 Update `two_factor_login_page.dart` and `verify_email_page.dart` with the same lifecycle-safe pattern
- [x] 1.4 Refactor `push_notification_service.dart` so navigation and localization access do not rely on stale context references
- [x] 1.5 Run focused verification and confirm the targeted warnings are resolved
