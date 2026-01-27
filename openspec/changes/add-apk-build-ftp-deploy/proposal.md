# Proposal: Add APK Build and FTP Deploy with In-App Update Check

## Summary

Add a GitHub Action workflow that can be manually triggered to build an Android APK, upload it to an FTP server, and automatically update a version manifest file. The Flutter app will check this manifest on startup to detect new versions and prompt users to download updates.

## Problem Statement

Currently, there is no automated way to:
1. Build release APKs from the repository
2. Distribute APKs to testers or users outside the Play Store
3. Notify users when a new version is available

This creates friction in the development and testing cycle, requiring manual APK builds and distribution.

## Proposed Solution

### 1. GitHub Action Workflow (`build-apk.yml`)

A manually triggered workflow (`workflow_dispatch`) that:
- Accepts version input (e.g., `1.2.0`) when triggered
- Updates `pubspec.yaml` with the new version
- Builds a release APK using Flutter
- Generates a `version.json` manifest with version info and download URL
- Uploads both the APK and `version.json` to the configured FTP server
- **Commits and pushes the version update back to the repository**
- Uses GitHub Secrets for FTP credentials (host, username, password)

### 2. In-App Update Check Service

A new `UpdateCheckService` in the Flutter app that:
- Fetches `version.json` from the FTP server on app startup
- Compares the remote version with the installed app version
- Shows a dialog prompting users to download the new APK when an update is available
- Provides a direct download link to the APK

### 3. Version Management

- Version is specified manually when triggering the workflow
- `pubspec.yaml` version is updated as part of the build process
- **The updated `pubspec.yaml` is committed and pushed back to the repository**, ensuring the source code always reflects the latest released version
- `version.json` contains: `version`, `buildNumber`, `downloadUrl`, `releaseDate`, `releaseNotes` (optional)

## Scope

### In Scope
- GitHub Action workflow for manual APK builds
- FTP upload of APK and version manifest
- Flutter service to check for updates
- Update dialog UI with download link
- Version comparison logic

### Out of Scope
- Automatic Play Store deployment
- iOS builds and distribution
- In-app APK installation (Android security restrictions)
- Force update mechanism (optional notification only)
- Backend API changes

## Success Criteria

1. Workflow can be triggered from GitHub Actions UI with version input
2. APK is successfully built and uploaded to FTP
3. `version.json` is accessible at the configured URL
4. **`pubspec.yaml` is updated and committed back to the repository with the new version**
5. App detects new version on startup and shows update dialog
6. Download link correctly points to the uploaded APK

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| FTP credentials exposure | Use GitHub encrypted secrets |
| Network failures during upload | Implement retry logic in workflow |
| Version check slowing app startup | Perform check asynchronously, non-blocking |
| Users on old versions not seeing updates | Check on every app launch, not just first |
| Version commit conflicts with concurrent changes | Workflow runs on main branch; coordinate releases to avoid conflicts |

## Dependencies

- GitHub Actions (already configured)
- FTP server with write access (user-provided)
- Flutter build toolchain

## Affected Components

- `.github/workflows/` - New workflow file
- `pubspec.yaml` - Version updated automatically by workflow
- `lib/shared/services/` - New update check service
- `lib/core/models/` - New version info model
- `lib/shared/providers/` - Update check provider
- `lib/app/` - Integration at app startup
