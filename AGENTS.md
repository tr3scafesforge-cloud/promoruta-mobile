# AGENTS.md - Instructions for AI Coding Assistants

This file contains guidelines, commands, and conventions for AI agents working on the PromoRuta Flutter project.

## Build/Test/Lint Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for release
flutter build apk --release
flutter build ios --release

# Run tests
flutter test

# Run a specific test file
flutter test test/features/promotor/route_execution/presentation/providers/campaign_execution_notifier_test.dart

# Run tests with coverage
flutter test --coverage

# Lint and analyze
flutter analyze

# Format code
dart format .

# Generate code (for build_runner, riverpod, drift, etc.)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### Development Workflow
1. Always run `flutter pub get` after modifying pubspec.yaml
2. Use `flutter analyze` before committing to check for issues
3. Run `flutter test` to ensure all tests pass
4. Use `dart format .` to maintain consistent formatting

## Project Architecture

### Directory Structure
```
lib/
├── app/                    # App-level configuration
│   ├── routes/            # Routing setup
│   └── theme.dart         # App theming
├── core/                  # Shared core functionality
│   ├── models/           # Domain models
│   ├── utils/            # Utility functions
│   └── constants/        # App constants
├── features/             # Feature-based organization
│   ├── promotor/         # Promoter features
│   └── advertiser/       # Advertiser features
├── shared/               # Cross-cutting concerns
│   ├── services/         # Shared services
│   ├── widgets/          # Reusable widgets
│   ├── datasources/      # Data sources
│   └── providers/        # Riverpod providers
└── presentation/         # Legacy presentation layer
```

### Feature Structure
Each feature follows clean architecture:
```
features/[feature_name]/
├── domain/
│   ├── models/           # Domain models
│   ├── repositories/     # Repository interfaces
│   └── use_cases/        # Business logic
├── data/
│   ├── datasources/      # Data source implementations
│   ├── repositories/     # Repository implementations
│   └── services/         # Data services
└── presentation/
    ├── pages/            # UI pages
    ├── widgets/          # Feature-specific widgets
    └── providers/        # State management
```

## Code Style Guidelines

### Import Organization
```dart
// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Package imports
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

// Project imports (absolute paths)
import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/shared/services/config_service.dart';
import 'package:promoruta/features/promotor/domain/models/campaign.dart';
```

### Naming Conventions
- **Files**: snake_case (e.g., `campaign_execution_notifier.dart`)
- **Classes**: PascalCase (e.g., `CampaignExecutionNotifier`)
- **Variables/Methods**: camelCase (e.g., `campaignExecutionState`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `BATCH_SYNC_THRESHOLD`)
- **Private members**: prefix with underscore (e.g., `_syncTimer`)

### State Management (Riverpod)
```dart
// Provider definitions
final campaignExecutionProvider = StateNotifierProvider<CampaignExecutionNotifier, CampaignExecutionState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final syncUseCase = ref.watch(syncGpsPointsUseCaseProvider);
  return CampaignExecutionNotifier(locationService, syncUseCase);
});

// Notifier pattern
class CampaignExecutionNotifier extends StateNotifier<CampaignExecutionState> {
  CampaignExecutionNotifier(this._locationService, this._syncUseCase)
      : super(CampaignExecutionState.idle());
  
  Future<void> startCampaign(String campaignId) async {
    state = state.copyWith(isLoading: true);
    try {
      // Implementation
      state = state.copyWith(isActive: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

### Error Handling
```dart
// Use Result pattern or try-catch with proper error states
Future<Result<void>> startCampaign() async {
  try {
    await _repository.startCampaign();
    return Result.success(null);
  } catch (e) {
    Logger.e('Failed to start campaign', error: e);
    return Result.failure(e.toString());
  }
}

// In UI, handle loading/error states
Widget build(BuildContext context) {
  return state.when(
    idle: () => const StartButton(),
    loading: () => const CircularProgressIndicator(),
    active: () => const ActiveCampaignView(),
    error: (error) => ErrorMessage(message: error),
  );
}
```

### Testing Guidelines
```dart
// Use mocktail for mocking
class MockLocationService extends Mock implements LocationService {}

// Test structure
void main() {
  group('CampaignExecutionNotifier', () {
    late MockLocationService mockLocationService;
    late CampaignExecutionNotifier notifier;

    setUp(() {
      mockLocationService = MockLocationService();
      notifier = CampaignExecutionNotifier(mockLocationService, mockSyncUseCase);
    });

    test('should start campaign successfully', () async {
      // Arrange
      when(() => mockLocationService.hasPermission()).thenAnswer((_) async => true);
      
      // Act
      await notifier.startCampaign('test-campaign-id');
      
      // Assert
      expect(state.isActive, isTrue);
      verify(() => mockLocationService.hasPermission()).called(1);
    });
  });
}
```

## Dependencies and Tools

### Key Packages
- **State Management**: flutter_riverpod
- **Routing**: go_router
- **HTTP**: dio
- **Database**: drift (sqlite3_flutter_libs)
- **Location**: geolocator
- **Maps**: mapbox_maps_flutter
- **Localization**: flutter_localizations, intl
- **Testing**: flutter_test, mocktail

### Code Generation
- Run `flutter packages pub run build_runner build` after modifying:
  - Drift database entities
  - Riverpod annotations
  - Go Router builders
  - Flutter_gen assets

## Environment Configuration

### Environment Variables
- Use `.env` file for configuration
- Access via `Env` class in `shared/constants/env.dart`
- Never commit sensitive data to version control

### Map Configuration
- Mapbox access token configured in `main.dart`
- Map constants in `shared/constants/map_constants.dart`

## Git Workflow

### Before Committing
1. Run `flutter analyze` - fix all issues
2. Run `flutter test` - ensure all tests pass
3. Run `dart format .` - format code consistently
4. Check for any generated files that need updating

### Commit Message Style
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, etc.
- Be descriptive but concise
- Reference issue numbers when applicable

## Common Patterns

### Repository Pattern
```dart
abstract class CampaignRepository {
  Future<Result<List<Campaign>>> getCampaigns();
  Future<Result<void>> saveCampaign(Campaign campaign));
}

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignDataSource _dataSource;
  
  CampaignRepositoryImpl(this._dataSource);
  
  @override
  Future<Result<List<Campaign>>> getCampaigns() async {
    try {
      final campaigns = await _dataSource.getCampaigns();
      return Result.success(campaigns);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
```

### Service Layer
```dart
class LocationService {
  Future<bool> hasPermission() async {
    return await Geolocator.checkPermission() != LocationPermission.denied;
  }
  
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 5.0,
    );
  }
}
```

### Widget Composition
```dart
class CampaignCard extends ConsumerWidget {
  const CampaignCard({super.key, required this.campaign});
  
  final Campaign campaign;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(campaign.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(campaign.description),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () => _handleStartCampaign(context, ref),
            child: const Text('Start Campaign'),
          ),
        ],
      ),
    );
  }
}
```

## Performance Considerations

- Use const constructors where possible
- Implement proper disposal of streams and controllers
- Use lazy loading for expensive operations
- Optimize database queries with proper indexing
- Use image caching for network images

## Security Best Practices

- Never log sensitive information (tokens, passwords)
- Use secure storage for sensitive data
- Validate all user inputs
- Implement proper authentication and authorization
- Use HTTPS for all network requests

<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->