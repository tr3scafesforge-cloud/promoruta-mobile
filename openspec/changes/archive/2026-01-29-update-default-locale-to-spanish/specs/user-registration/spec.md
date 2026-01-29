## MODIFIED Requirements

### Requirement: Localization

The system SHALL display the registration flow in Spanish by default. Multi-language support (English, Portuguese) remains available in the codebase but is not user-selectable.

#### Scenario: Default locale is Spanish
- **WHEN** a new user installs and opens the app for the first time
- **THEN** all UI text is displayed in Spanish

#### Scenario: Language selector hidden
- **WHEN** a user navigates to the profile/settings page
- **THEN** no language selection option is visible

#### Scenario: Persisted locale override
- **WHEN** a user previously selected a locale before this change
- **AND** that preference is still stored in SharedPreferences
- **THEN** the persisted locale is used instead of the default
