# PromoRuta Mobile

Flutter mobile application for PromoRuta platform - connecting advertisers with promoters for mobile advertising campaigns.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Development](#development)
  - [Code Generation](#code-generation)
  - [Localization](#localization)
  - [Routes](#routes)
  - [Assets](#assets)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Testing](#testing)

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd promoruta_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add required configuration (see [Configuration](#configuration))

4. **Run code generation**
   ```bash
   # Generate all code (routes, assets, etc.)
   flutter pub run build_runner build --delete-conflicting-outputs

   # Generate localizations
   flutter gen-l10n
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Development

### Code Generation

This project uses code generation for routes, assets, and other boilerplate code.

#### Generate Routes and Assets

When you modify routes in `lib/app/routes/app_router.dart` or add new assets:

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Short command:**
```bash
dart run build_runner build -d
```

#### Generated Files

- `lib/app/routes/app_router.g.dart` - Auto-generated route definitions
- `lib/gen/assets.gen.dart` - Auto-generated asset references

### Localization

The app supports multiple languages using Flutter's internationalization (l10n).

#### Add New Translations

1. **Edit ARB files** in `lib/l10n/`:
   - `app_en.arb` - English translations
   - `app_es.arb` - Spanish translations

2. **Add a new string** (example):
   ```json
   {
     "yourNewKey": "Your translation text",
     "@yourNewKey": {
       "description": "Description of what this text is used for"
     }
   }
   ```

3. **Generate localization files**:
   ```bash
   flutter gen-l10n
   ```

4. **Use in code**:
   ```dart
   import 'package:promoruta/gen/l10n/app_localizations.dart';

   // In your widget
   final l10n = AppLocalizations.of(context);
   Text(l10n.yourNewKey)
   ```

#### Generated Files

- `lib/gen/l10n/app_localizations.dart` - Main localization class
- `lib/gen/l10n/app_localizations_en.dart` - English localizations
- `lib/gen/l10n/app_localizations_es.dart` - Spanish localizations

### Routes

The project uses `go_router` with code generation for type-safe routing.

#### Add a New Route

1. **Define the route** in `lib/app/routes/app_router.dart`:
   ```dart
   @TypedGoRoute<YourRoute>(
     path: '/your-path',
   )
   class YourRoute extends GoRouteData {
     const YourRoute();

     @override
     Widget build(BuildContext context, GoRouterState state) {
       return const YourPage();
     }
   }
   ```

2. **Generate route code**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Navigate to the route**:
   ```dart
   // Push navigation
   const YourRoute().push(context);

   // Go navigation (replace)
   const YourRoute().go(context);
   ```

#### Route Parameters

For routes with parameters:
```dart
@TypedGoRoute<DetailRoute>(
  path: '/detail/:id',
)
class DetailRoute extends GoRouteData {
  final String id;

  const DetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DetailPage(id: id);
  }
}
```

### Assets

Assets are automatically indexed using `flutter_gen`.

#### Add New Assets

1. **Add files** to the appropriate directory:
   - `assets/images/` - Image files
   - `assets/icons/` - Icon files
   - `assets/config/` - Configuration files

2. **Update `pubspec.yaml`** if needed (ensure assets directory is declared)

3. **Generate asset references**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Use in code**:
   ```dart
   import 'package:promoruta/gen/assets.gen.dart';

   // Images
   Image.asset(Assets.images.logo.path)

   // Config files
   final config = Assets.config.appConfig;
   ```

## Project Structure

```
lib/
├── app/                    # App-level configuration
│   └── routes/            # Route definitions
├── core/                  # Core utilities and constants
│   ├── constants/         # App constants
│   ├── models/           # Core data models
│   ├── theme.dart        # Theme configuration
│   └── utils/            # Utility functions
├── features/             # Feature modules
│   ├── advertiser/       # Advertiser features
│   │   ├── campaign_creation/
│   │   ├── campaign_management/
│   │   └── presentation/
│   ├── auth/            # Authentication
│   ├── profile/         # User profile
│   └── promotor/        # Promoter features
├── gen/                 # Generated files (DO NOT EDIT)
│   ├── assets.gen.dart
│   └── l10n/
├── l10n/               # Localization ARB files
│   ├── app_en.arb
│   └── app_es.arb
└── shared/             # Shared widgets, providers, services
    ├── providers/
    ├── services/
    └── widgets/
```

## Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# API Configuration
API_BASE_URL=https://your-api-url.com/api
```

### App Configuration

Configuration is managed through:
- `assets/config/app_config.json` - App configuration
- `lib/core/models/config.dart` - Configuration models
- `lib/shared/services/config_service.dart` - Configuration service

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/path/to/test_file.dart
```

## Code Analysis

```bash
# Run static analysis
flutter analyze

# Format code
dart format lib/

# Fix formatting issues
dart fix --apply
```

## Build

### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### iOS
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## Common Commands Reference

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter gen-l10n` | Generate localization files |
| `flutter pub run build_runner build -d` | Generate routes and assets |
| `flutter pub run build_runner watch -d` | Watch mode for code generation |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run tests |
| `flutter clean` | Clean build artifacts |

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - Project architecture overview
- [Mapbox Setup](docs/MAPBOX_SETUP.md) - Mapbox integration guide
- [Mapbox Tests](docs/MAPBOX_TESTS_README.md) - Mapbox testing documentation

## Troubleshooting

### Code generation issues
```bash
# Clean generated files and rebuild
flutter pub run build_runner clean
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Localization not updating
```bash
# Clean and regenerate
flutter clean
flutter gen-l10n
flutter pub get
```

### Dependency conflicts
```bash
# Update dependencies
flutter pub upgrade
flutter pub get
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and analysis
4. Submit a pull request

## License

[License information]