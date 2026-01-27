# app-update-check Specification

## Purpose
TBD - created by archiving change add-apk-build-ftp-deploy. Update Purpose after archive.
## Requirements
### Requirement: Version Manifest Fetching

The app MUST fetch version information from a remote manifest file to determine if updates are available.

#### Scenario: Successful version check on app startup
- **Given** the user has launched the app and is authenticated
- **When** the app performs a background version check
- **Then** the app fetches `version.json` from the configured URL
- **And** parses the version information successfully

#### Scenario: Network timeout during version check
- **Given** the user has launched the app
- **When** the version check request exceeds 10 seconds
- **Then** the check fails silently without blocking app usage
- **And** the user proceeds to the app normally

#### Scenario: Invalid version manifest
- **Given** the user has launched the app
- **When** the `version.json` contains invalid or unparseable content
- **Then** the check fails silently
- **And** the error is logged for debugging purposes

---

### Requirement: Version Comparison

The app MUST compare the installed version with the remote version using semantic versioning to determine if an update is available.

#### Scenario: Update available
- **Given** the installed app version is "1.0.0"
- **When** the remote version is "1.1.0"
- **Then** the system determines an update is available

#### Scenario: App is up to date
- **Given** the installed app version is "1.1.0"
- **When** the remote version is "1.1.0"
- **Then** the system determines no update is available

#### Scenario: App is newer than remote
- **Given** the installed app version is "1.2.0"
- **When** the remote version is "1.1.0"
- **Then** the system determines no update is available

#### Scenario: Semantic version comparison
- **Given** the installed version is "1.9.0"
- **When** the remote version is "1.10.0"
- **Then** the system correctly determines "1.10.0" is newer
- **And** identifies an update is available

---

### Requirement: Update Dialog Display

The app MUST display an update dialog when a new version is detected, allowing users to download or dismiss.

#### Scenario: Update dialog shown
- **Given** an update is available
- **When** the version check completes
- **Then** an update dialog is displayed
- **And** the dialog shows the new version number
- **And** the dialog shows a "Download" button
- **And** the dialog shows a "Later" button

#### Scenario: Update dialog with release notes
- **Given** an update is available
- **And** the version manifest includes release notes
- **When** the update dialog is displayed
- **Then** the release notes are shown in the dialog

#### Scenario: User initiates download
- **Given** the update dialog is displayed
- **When** the user taps the "Download" button
- **Then** the device browser opens with the APK download URL

#### Scenario: User dismisses update dialog
- **Given** the update dialog is displayed
- **When** the user taps the "Later" button
- **Then** the dialog is dismissed
- **And** the user proceeds to use the app normally

---

### Requirement: Non-Blocking Update Check

The update check MUST NOT block or delay the user's ability to use the app.

#### Scenario: App remains usable during check
- **Given** the user has authenticated
- **When** the version check is in progress
- **Then** the user can navigate and use the app normally

#### Scenario: App continues on check failure
- **Given** the version check fails for any reason
- **When** the failure occurs
- **Then** the app continues to function normally
- **And** no error is shown to the user

