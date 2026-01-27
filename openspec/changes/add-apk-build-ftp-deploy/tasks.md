# Tasks: Add APK Build and FTP Deploy with In-App Update Check

## Prerequisites

- [ ] Obtain FTP server credentials from infrastructure team
- [ ] Configure GitHub repository secrets: `FTP_HOST`, `FTP_USERNAME`, `FTP_PASSWORD`, `FTP_BASE_URL`

## Phase 1: GitHub Action Workflow

- [x] Create `.github/workflows/build-apk.yml` workflow file
- [x] Configure workflow_dispatch trigger with version input
- [x] Add `contents: write` permission for pushing commits
- [x] Add Flutter setup step (matching existing workflow Flutter version)
- [x] Add step to update `pubspec.yaml` version from input
- [x] Add APK build step with `flutter build apk --release`
- [x] Add step to generate `version.json` manifest
- [x] Add FTP upload step for APK file
- [x] Add FTP upload step for `version.json`
- [x] Add step to commit and push `pubspec.yaml` version update
- [x] Configure git user as `github-actions[bot]` for commits
- [ ] Test workflow with a test version number
- [ ] Verify version commit appears in repository history

## Phase 2: Flutter Version Model

- [x] Create `lib/core/models/version_info.dart` with `VersionInfo` class
- [x] Add JSON serialization methods (`fromJson`, `toJson`)
- [x] Add version comparison helper method

## Phase 3: Update Check Service

- [x] Create `lib/shared/services/update_check_service.dart` interface
- [x] Create `lib/shared/services/update_check_service_impl.dart` implementation
- [x] Implement `checkForUpdates()` method to fetch `version.json`
- [x] Implement `getCurrentAppVersion()` using package_info_plus
- [x] Implement semantic version comparison logic
- [x] Add timeout and error handling for network requests
- [x] Add `package_info_plus` dependency to `pubspec.yaml`

## Phase 4: Riverpod Provider

- [x] Add providers to `lib/shared/providers/providers.dart`
- [x] Implement async provider that checks for updates
- [x] Expose update state (checking, available, not available, error)
- [x] Register provider in appropriate scope

## Phase 5: Update Dialog UI

- [x] Create `lib/shared/widgets/update_dialog.dart`
- [x] Design dialog with version info display
- [x] Add release notes section (if available)
- [x] Add "Download" button that opens APK URL in browser
- [x] Add "Later" button to dismiss dialog
- [x] Add localization strings for dialog text (EN, ES, PT)

## Phase 6: App Integration

- [x] Create `lib/shared/widgets/update_check_wrapper.dart`
- [x] Integrate update check at app startup (after authentication)
- [x] Show update dialog when update is available
- [x] Ensure check is non-blocking and async
- [x] Add configuration for version check URL in `AppConfig`

## Phase 7: Testing

- [x] Write unit tests for version comparison logic
- [x] Write unit tests for `VersionInfo` model serialization
- [ ] Test GitHub workflow with a dry-run deployment
- [ ] Test update dialog appearance and behavior
- [ ] Verify FTP upload creates correct file structure

## Phase 8: Documentation

- [ ] Update README with workflow usage instructions
- [ ] Document required GitHub secrets
- [ ] Add instructions for triggering manual builds
