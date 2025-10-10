# Dynamic Configuration System

## Overview

The app uses a dynamic configuration system to manage API base URLs, allowing changes without app updates.

## Architecture

```
App Startup → ConfigService.getConfig()
                    ↓
            Try Remote Config API
                    ↓ (if fails)
              Load Cached Config
                    ↓ (if none)
            Load Assets Config
```

## Components

### 1. AppConfig Model
- Stores baseUrl and configVersion
- Located: `lib/core/models/config.dart`

### 2. ConfigService
- Manages config loading with fallback strategy
- Caches config in SharedPreferences
- Located: `lib/shared/services/config_service.dart`

### 3. Assets Config
- Default config bundled with app
- Located: `assets/config/app_config.json`

### 4. API URL Structure
- **Base URL includes API prefix**: The baseUrl should include the `/api/` path segment
- **Example**: `"baseUrl": "https://api.example.com/api/"`
- **Endpoint paths**: Relative paths like `/auth/login` become `https://api.example.com/api/auth/login`
- **Decision**: `/api/` is part of baseUrl (not endpoint paths) to match backend API structure

### 4. Remote Config API (Future)
- Optional endpoint to fetch config dynamically
- Should return JSON: `{"baseUrl": "https://api.example.com/api/", "configVersion": "1.0.0"}`

## Usage

### Setting Remote Config URL
In `lib/shared/providers/providers.dart`, update the configServiceProvider:

```dart
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigServiceImpl(
    remoteConfigUrl: 'https://your-config-server.com/api/config',
  );
});
```

**Note**: The remote config response should include `/api/` in the baseUrl:
```json
{
  "baseUrl": "https://api.example.com/api/",
  "configVersion": "1.0.0"
}
```

### Updating Production URL
1. **Without App Update**: Change the remote config API response
2. **With App Update**: Modify `assets/config/app_config.json`

## Fallback Strategy

1. **Primary**: Remote config (if URL provided)
2. **Secondary**: Cached config from previous successful fetch
3. **Tertiary**: Assets config (always available)

## Error Handling

- Network failures fall back to cached/assets config
- Invalid JSON falls back to assets config
- App continues to function with last known good config

## Security Considerations

- Remote config endpoint should be HTTPS
- Consider authentication for config endpoint
- Validate config data before using

## Testing

Test scenarios:
- Fresh install (uses assets)
- Network unavailable (uses cache/assets)
- Invalid remote response (falls back)
- Config updates (refreshes on next app launch)