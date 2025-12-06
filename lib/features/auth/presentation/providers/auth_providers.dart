// Auth Feature Providers
// This file re-exports the auth providers from the shared providers file
// to maintain backward compatibility and provide a clean feature API.

// Export permission provider (auth-specific)
export 'permission_provider.dart';

// NOTE: Auth data sources, repositories, use cases, and state providers
// are defined in lib/shared/providers/providers.dart because they need
// to be accessed by shared infrastructure (like TokenRefreshInterceptor).
//
// To use auth providers, import them from:
// - lib/shared/providers/providers.dart (for authStateProvider, authRepositoryProvider, etc.)
//
// Once we fully migrate to feature-first, these will move here.
