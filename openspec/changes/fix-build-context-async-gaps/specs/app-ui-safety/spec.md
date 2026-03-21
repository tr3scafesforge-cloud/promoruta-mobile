## ADDED Requirements
### Requirement: Lifecycle-Safe BuildContext Usage
UI and app service flows SHALL NOT use `BuildContext` across asynchronous gaps unless lifecycle safety is explicitly verified before each use.

#### Scenario: Stateful auth page resumes after await
- **WHEN** an authentication page awaits a repository or use case call before showing UI feedback or navigation
- **THEN** it checks that the widget is still mounted, or it avoids using `BuildContext` captured before the async gap

#### Scenario: Notification flow performs async work before navigation
- **WHEN** push notification handling awaits user/session data before reading localization or routing
- **THEN** navigation and localized UI access are performed only after confirming the active context is still valid, or by using a context-free alternative

### Requirement: Targeted Analyzer Verification For Async Context Safety
Changes that touch known async-context warning sites SHALL include focused verification for those warning locations.

#### Scenario: Auth and notification warning sites are checked
- **WHEN** the affected auth pages or push notification service are modified
- **THEN** targeted verification confirms the known `use_build_context_synchronously` warnings are resolved or intentionally documented
