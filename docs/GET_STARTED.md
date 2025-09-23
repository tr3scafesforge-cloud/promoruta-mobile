# Getting Started with PromoRuta Mobile App

This guide will help you set up and run the PromoRuta mobile application on your local development environment.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.6.0 or higher
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart SDK**: Included with Flutter
- **Android Studio** or **VS Code** with Flutter extension
- **Android SDK** (for Android development)
- **Xcode** (for iOS development on macOS)

## Project Setup

1. **Clone the repository** (if applicable) or navigate to the project directory:
   ```bash
   cd path/to/promoruta_mobile
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code assets** (if using flutter_gen):
   ```bash
   flutter pub run build_runner build
   ```

## Running the App

### Android
1. **Connect an Android device** or start an Android emulator
2. Run the app:
   ```bash
   flutter run
   ```

### iOS (macOS only)
1. **Connect an iOS device** or start an iOS simulator
2. Run the app:
   ```bash
   flutter run
   ```

### Web (optional)
1. Enable web support:
   ```bash
   flutter config --enable-web
   ```
2. Run on web:
   ```bash
   flutter run -d chrome
   ```

## Development Workflow

### Code Generation
The project uses `flutter_gen` for asset generation. After adding new assets, run:
```bash
flutter pub run build_runner build
```

### Testing
Run tests:
```bash
flutter test
```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### iOS (macOS only)
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## Project Structure

```
lib/
├── app/                 # App-level configurations
├── core/                # Core utilities, models, services
├── features/            # Feature-based modules
│   ├── auth/           # Authentication features
│   ├── advertiser/     # Advertiser features
│   └── promotor/       # Promotor features
├── presentation/        # UI screens and widgets
└── shared/             # Shared utilities and widgets

docs/                   # Documentation
android/                # Android-specific code
ios/                    # iOS-specific code
```

## Key Features

- **Onboarding Flow**: Swipeable onboarding screens with dots indicator
- **Authentication**: Login and role selection
- **Home Screen**: Main app interface
- **Persistent Storage**: Onboarding completion and user preferences

## Troubleshooting

### Common Issues

1. **Flutter doctor issues**:
   ```bash
   flutter doctor
   ```
   Fix any reported issues.

2. **Dependency conflicts**:
   ```bash
   flutter pub cache repair
   flutter pub get
   ```

3. **Emulator issues**:
   - Ensure Android Studio SDK is properly configured
   - For iOS, ensure Xcode is installed and simulators are available

4. **Build failures**:
   - Clean and rebuild:
     ```bash
     flutter clean
     flutter pub get
     flutter run
     ```

### Getting Help

- Check Flutter documentation: https://flutter.dev/docs
- Join Flutter community: https://flutter.dev/community
- Report issues in the project repository

## Next Steps

After setting up the project:

1. Explore the onboarding flow
2. Review the authentication implementation
3. Add new features following the existing architecture
4. Write tests for new functionality
5. Update this documentation as needed

Happy coding! 🚀