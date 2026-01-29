# app-appearance Specification

## Purpose
TBD - created by archiving change update-default-theme-to-light. Update Purpose after archive.
## Requirements
### Requirement: Default Light Theme

The application SHALL use light theme by default. Theme switching is not exposed to users.

#### Scenario: New installation uses light theme
- **WHEN** a user installs and opens the app for the first time
- **THEN** the app displays in light theme

#### Scenario: Theme toggle hidden
- **WHEN** a user navigates to the profile/settings page
- **THEN** no theme toggle option is visible

