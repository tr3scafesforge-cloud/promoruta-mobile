# Design: APK Build and FTP Deploy with In-App Update Check

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Actions                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  workflow_dispatch (manual trigger)                      │    │
│  │  ├── Input: version (e.g., "1.2.0")                     │    │
│  │  ├── Input: release_notes (optional)                    │    │
│  │  └── Input: build_number (optional, auto-incremented)   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           │                                      │
│                           ▼                                      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Build Steps                                             │    │
│  │  1. Checkout code                                        │    │
│  │  2. Setup Flutter                                        │    │
│  │  3. Update pubspec.yaml version                         │    │
│  │  4. Build APK (flutter build apk --release)             │    │
│  │  5. Generate version.json                               │    │
│  │  6. Upload APK + version.json to FTP                    │    │
│  │  7. Commit & push pubspec.yaml version update           │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FTP Server                                  │
│  /promoruta/                                                     │
│  ├── releases/                                                   │
│  │   ├── promoruta-1.2.0.apk                                    │
│  │   └── promoruta-1.1.0.apk (previous)                         │
│  └── version.json                                                │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter App                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  UpdateCheckService                                      │    │
│  │  ├── checkForUpdates() → VersionInfo?                   │    │
│  │  ├── getCurrentAppVersion() → String                    │    │
│  │  └── compareVersions(current, remote) → bool            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           │                                      │
│                           ▼                                      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  UpdateCheckProvider (Riverpod)                         │    │
│  │  ├── Async check on app startup                         │    │
│  │  └── Exposes update state to UI                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           │                                      │
│                           ▼                                      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  UpdateDialog Widget                                     │    │
│  │  ├── Shows version info and release notes               │    │
│  │  ├── "Download" button → opens download URL             │    │
│  │  └── "Later" button → dismisses dialog                  │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## GitHub Secrets Required

| Secret Name | Description |
|-------------|-------------|
| `FTP_HOST` | FTP server hostname (e.g., `ftp.example.com`) |
| `FTP_USERNAME` | FTP account username |
| `FTP_PASSWORD` | FTP account password |
| `FTP_BASE_URL` | Public URL base for downloads (e.g., `https://downloads.example.com/promoruta`) |

## version.json Schema

```json
{
  "version": "1.2.0",
  "buildNumber": 12,
  "downloadUrl": "https://downloads.example.com/promoruta/releases/promoruta-1.2.0.apk",
  "releaseDate": "2026-01-25T10:30:00Z",
  "releaseNotes": "- Bug fixes\n- Performance improvements",
  "minSupportedVersion": "1.0.0"
}
```

## Flutter Implementation Details

### VersionInfo Model

```dart
class VersionInfo {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final DateTime releaseDate;
  final String? releaseNotes;
  final String? minSupportedVersion;
}
```

### UpdateCheckService

Location: `lib/shared/services/update_check_service.dart`

```dart
abstract class UpdateCheckService {
  Future<VersionInfo?> checkForUpdates();
  String getCurrentAppVersion();
  bool isUpdateAvailable(String currentVersion, String remoteVersion);
}
```

### Version Comparison Algorithm

Uses semantic versioning comparison:
1. Parse version strings into major.minor.patch components
2. Compare major first, then minor, then patch
3. Return true if remote version is greater than current

### Integration Point

The update check will be triggered in `lib/app/app.dart` or the main navigation wrapper, after successful authentication. The check runs asynchronously and does not block app startup.

### User Flow

1. User opens app
2. App authenticates user (existing flow)
3. After auth, `UpdateCheckProvider` fetches `version.json` in background
4. If update available:
   - Show `UpdateDialog` with version info
   - User can tap "Download" → opens browser to download APK
   - User can tap "Later" → dialog dismissed, proceeds to app
5. If no update or network error → proceed silently

## GitHub Workflow Design

### Workflow Inputs

```yaml
inputs:
  version:
    description: 'Version number (e.g., 1.2.0)'
    required: true
    type: string
  release_notes:
    description: 'Release notes (optional)'
    required: false
    type: string
    default: ''
```

### Build Artifact Naming

APK files will be named: `promoruta-{version}.apk`
- Example: `promoruta-1.2.0.apk`

### FTP Upload Strategy

Using `SamKirkland/FTP-Deploy-Action` or `lftp` for reliable FTP uploads with:
- Retry on failure
- Passive mode support
- TLS/SSL support if available

### Version Commit Strategy

After successful build and FTP upload, the workflow commits the updated `pubspec.yaml` back to the repository:

```yaml
- name: Commit version update
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add pubspec.yaml
    git commit -m "chore: bump version to ${{ inputs.version }}"
    git push
```

**Key considerations:**
- Uses `github-actions[bot]` as the commit author for traceability
- Only commits `pubspec.yaml` to avoid unintended changes
- Commit message follows conventional commits format
- Requires `contents: write` permission in the workflow
- Push occurs after FTP upload succeeds to ensure consistency

## Error Handling

### Network Failures
- Update check timeout: 10 seconds
- On failure: silently continue (non-blocking)
- Log error for debugging

### Invalid version.json
- Parse errors logged
- App continues without update prompt

### FTP Upload Failures
- Workflow fails with clear error message
- No partial uploads (atomic operation)

## Security Considerations

1. **FTP Credentials**: Stored as GitHub encrypted secrets, never in code
2. **Download URLs**: Use HTTPS when possible for download links
3. **Version Manifest**: Public read access, write access restricted to CI/CD
4. **APK Signing**: Uses debug signing for now (TODO: add release keystore in future)

## Future Enhancements (Out of Scope)

- Release keystore management via GitHub secrets
- Force update based on `minSupportedVersion`
- Delta updates
- Play Store integration
- iOS TestFlight builds
