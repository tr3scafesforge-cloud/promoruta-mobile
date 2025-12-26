import 'package:promoruta/core/models/user.dart';

class RouteGuard {
  final List<UserRole>? allowedRoles;
  final bool requiresAuth;

  const RouteGuard({
    this.allowedRoles,
    this.requiresAuth = true,
  });

  bool canAccess(UserRole? userRole) {
    if (!requiresAuth) return true;
    if (userRole == null) return false;
    if (allowedRoles == null) return true;
    return allowedRoles!.contains(userRole);
  }
}

class RouteGuards {
  static const publicRoutes = RouteGuard(requiresAuth: false);
  static const authenticatedRoutes = RouteGuard(requiresAuth: true);
  static const promoterOnly = RouteGuard(
    allowedRoles: [UserRole.promoter],
    requiresAuth: true,
  );
  static const advertiserOnly = RouteGuard(
    allowedRoles: [UserRole.advertiser],
    requiresAuth: true,
  );

  static final Map<String, RouteGuard> guards = {
    // Public routes
    '/': publicRoutes,
    '/onboarding': publicRoutes,
    '/login': publicRoutes,
    '/choose-role': publicRoutes,
    '/start': publicRoutes,

    // Authenticated routes (any role)
    '/home': authenticatedRoutes,
    '/permissions': authenticatedRoutes,
    '/language-settings': authenticatedRoutes,
    '/user-profile': authenticatedRoutes,

    // Promoter-only routes
    '/promoter-home': promoterOnly,

    // Advertiser-only routes
    '/advertiser-home': advertiserOnly,
    '/advertiser-security-settings': advertiserOnly,
    '/payment-methods': advertiserOnly,
    '/change-password': advertiserOnly,
    '/two-factor-auth': advertiserOnly,
    '/create-campaign': advertiserOnly,
    '/campaign-details/:campaignId': advertiserOnly,
  };

  static RouteGuard? getGuard(String path) {
    // Check exact match first
    if (guards.containsKey(path)) {
      return guards[path];
    }

    // Check for parameterized routes (e.g., /campaign-details/:campaignId)
    for (final entry in guards.entries) {
      if (entry.key.contains(':')) {
        final pattern = entry.key.replaceAll(RegExp(r':[^/]+'), '[^/]+');
        if (RegExp('^$pattern\$').hasMatch(path)) {
          return entry.value;
        }
      }
    }

    // Default to requiring authentication
    return authenticatedRoutes;
  }
}
