# APK Build and FTP Deploy with In-App Update Check

This guide explains how to build and distribute APKs using GitHub Actions, and how the in-app update check works.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [1. Configure GitHub Secrets](#1-configure-github-secrets)
  - [2. Configure Version Check URL](#2-configure-version-check-url)
  - [3. Run Code Generation](#3-run-code-generation)
- [Usage](#usage)
  - [Triggering a Build](#triggering-a-build)
  - [Build Outputs](#build-outputs)
- [How It Works](#how-it-works)
  - [GitHub Action Workflow](#github-action-workflow)
  - [In-App Update Check](#in-app-update-check)
  - [Version Comparison](#version-comparison)
- [Configuration Reference](#configuration-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview

This feature provides:

1. **Manual APK Builds**: Trigger APK builds directly from GitHub Actions
2. **FTP Distribution**: Automatically upload APKs to your FTP server
3. **Version Management**: Automatically update `pubspec.yaml` and commit the change
4. **In-App Updates**: Users are notified when a new version is available

---

## Prerequisites

Before using this feature, ensure you have:

- [ ] Access to a GitHub repository with Actions enabled
- [ ] An FTP server with write access
- [ ] FTP credentials (host, username, password)
- [ ] A public URL where the FTP files can be accessed

---

## Setup

### 1. Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `FTP_HOST` | FTP server hostname | `ftp.example.com` |
| `FTP_USERNAME` | FTP account username | `deploy_user` |
| `FTP_PASSWORD` | FTP account password | `your_secure_password` |
| `FTP_BASE_URL` | Public URL base for downloads | `https://downloads.example.com/promoruta` |

> **Security Note**: Never commit FTP credentials to the repository. Always use GitHub Secrets.

### 2. Configure Version Check URL

Update the app configuration file to point to your version manifest:

**File**: `assets/config/app_config.json`

```json
{
  "baseUrl": "http://your-api-server.com/api/",
  "configVersion": "1.0.0",
  "versionCheckUrl": "https://your-ftp-server.com/version.json"
}
```

Replace `https://your-ftp-server.com/version.json` with the actual URL where `version.json` will be accessible after FTP upload.

### 3. Run Code Generation

After setup, run the following commands to regenerate code:

```bash
# Install dependencies
flutter pub get

# Generate localization and router files
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Usage

### Triggering a Build

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Select **"Build and Deploy APK"** from the left sidebar
4. Click **"Run workflow"** button
5. Fill in the inputs:

| Input | Required | Description | Example |
|-------|----------|-------------|---------|
| Version | Yes | Semantic version number | `1.2.0` |
| Build Number | No | Build number (defaults to GitHub run number) | `42` |
| Release Notes | No | What's new in this version | `Bug fixes and improvements` |

6. Click **"Run workflow"**

### Build Outputs

After a successful build:

1. **APK File**: Uploaded to FTP at `releases/promoruta-{version}.apk`
2. **Version Manifest**: Uploaded to FTP as `version.json`
3. **GitHub Artifact**: APK available for download in the workflow run
4. **Version Commit**: `pubspec.yaml` updated and committed to the repository

---

## How It Works

### GitHub Action Workflow

The workflow (`.github/workflows/build-apk.yml`) performs these steps:

```
1. Checkout code
2. Setup Flutter
3. Update pubspec.yaml with new version
4. Build release APK
5. Generate version.json manifest
6. Upload APK to FTP
7. Upload version.json to FTP
8. Commit version update to repository
```

### In-App Update Check

When users open the app:

1. After authentication, the app fetches `version.json` from the configured URL
2. The remote version is compared with the installed app version
3. If a newer version is available, an update dialog is shown
4. Users can tap "Download" to open the browser and download the APK
5. Users can tap "Later" to dismiss and continue using the app

### Version Comparison

Versions are compared using semantic versioning (major.minor.patch):

- `1.0.0` → `1.0.1` = Update available (patch)
- `1.0.0` → `1.1.0` = Update available (minor)
- `1.0.0` → `2.0.0` = Update available (major)
- `1.1.0` → `1.0.0` = No update (current is newer)
- `1.0.0` → `1.0.0` = No update (same version)

---

## Configuration Reference

### version.json Schema

The version manifest uploaded to FTP has this structure:

```json
{
  "version": "1.2.0",
  "buildNumber": 42,
  "downloadUrl": "https://downloads.example.com/promoruta/releases/promoruta-1.2.0.apk",
  "releaseDate": "2024-01-15T10:30:00Z",
  "releaseNotes": "Bug fixes and improvements"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `version` | String | Semantic version (e.g., "1.2.0") |
| `buildNumber` | Integer | Build number |
| `downloadUrl` | String | Full URL to download the APK |
| `releaseDate` | String | ISO 8601 timestamp |
| `releaseNotes` | String | Optional release notes |

### FTP Directory Structure

After deployment, your FTP server will have:

```
/
├── version.json          # Version manifest
└── releases/
    ├── promoruta-1.0.0.apk
    ├── promoruta-1.1.0.apk
    └── promoruta-1.2.0.apk  # Latest
```

---

## Troubleshooting

### Build Fails: Flutter Setup Error

**Problem**: Flutter setup step fails in GitHub Actions.

**Solution**: Ensure the Flutter version in the workflow matches your project requirements. Check `.github/workflows/build-apk.yml` and update the `flutter-version` if needed.

### FTP Upload Fails

**Problem**: FTP upload step fails with authentication error.

**Solution**:
1. Verify FTP credentials in GitHub Secrets
2. Ensure FTP server allows connections from GitHub Actions IPs
3. Check if FTP server requires TLS/SSL

### Version Check Not Working

**Problem**: App doesn't show update dialog even when new version is available.

**Solution**:
1. Verify `versionCheckUrl` in `assets/config/app_config.json` is correct
2. Ensure `version.json` is accessible at the configured URL
3. Check network connectivity on the device
4. Verify the remote version is actually newer than installed version

### Update Dialog Shows But Download Fails

**Problem**: User taps "Download" but browser shows error.

**Solution**:
1. Verify `FTP_BASE_URL` secret is correct
2. Ensure APK files are publicly accessible on the FTP server
3. Check if HTTPS is properly configured for the download URL

### Commit Fails: Permission Denied

**Problem**: Version commit step fails with permission error.

**Solution**:
1. Ensure the workflow has `contents: write` permission (already configured)
2. Check if branch protection rules are blocking the push
3. Verify the `GITHUB_TOKEN` has sufficient permissions

---

## Related Files

| File | Purpose |
|------|---------|
| `.github/workflows/build-apk.yml` | GitHub Action workflow |
| `lib/core/models/version_info.dart` | Version info model |
| `lib/shared/services/update_check_service.dart` | Update check service interface |
| `lib/shared/services/update_check_service_impl.dart` | Update check implementation |
| `lib/shared/widgets/update_dialog.dart` | Update dialog UI |
| `lib/shared/widgets/update_check_wrapper.dart` | Home screen wrapper |
| `lib/shared/providers/providers.dart` | Riverpod providers |
| `assets/config/app_config.json` | App configuration |

---

## Support

For issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review GitHub Actions logs for build errors
- Ensure all prerequisites are met
