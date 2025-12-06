import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/features/auth/choose_role.dart';
import 'package:promoruta/features/auth/login.dart';
import 'package:promoruta/features/auth/onboarding_page_view.dart';
import 'package:promoruta/features/auth/permissions.dart';
import 'package:promoruta/features/auth/start_page.dart';
import 'package:promoruta/presentation/home_screen.dart';
import 'package:promoruta/presentation/promotor/promoter_home_screen.dart';
import 'package:promoruta/presentation/advertiser/advertiser_home_screen.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_security_settings_page.dart';
import 'package:promoruta/presentation/advertiser/pages/language_settings_page.dart';
import 'package:promoruta/presentation/advertiser/pages/user_profile_page.dart';
import 'package:promoruta/presentation/advertiser/pages/payment_methods_page.dart';
import 'package:promoruta/presentation/advertiser/pages/change_password_page.dart';
import 'package:promoruta/presentation/advertiser/pages/two_factor_auth_page.dart';
import 'package:promoruta/features/advertiser/campaign_creation/presentation/pages/create_campaign_page.dart';
import 'package:promoruta/shared/shared.dart';

part 'app_router.g.dart';

@TypedGoRoute<AppStartupRoute>(
  path: '/',
)
class AppStartupRoute extends GoRouteData with _$AppStartupRoute {
  const AppStartupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppStartup();
  }
}

@TypedGoRoute<OnboardingRoute>(
  path: '/onboarding',
)
class OnboardingRoute extends GoRouteData with _$OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingPageView();
  }
}

@TypedGoRoute<HomeRoute>(
  path: '/home',
)
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

@TypedGoRoute<LoginRoute>(
  path: '/login',
)
class LoginRoute extends GoRouteData with _$LoginRoute {
  const LoginRoute({this.role});

  final model.UserRole? role;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final roleParam = state.uri.queryParameters['role'];
    final userRole = roleParam != null
        ? model.UserRole.fromString(roleParam)
        : model.UserRole.promoter;
    return Login(role: userRole);
  }
}

@TypedGoRoute<ChooseRoleRoute>(
  path: '/choose-role',
)
class ChooseRoleRoute extends GoRouteData with _$ChooseRoleRoute {
  const ChooseRoleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChooseRole();
  }
}

@TypedGoRoute<PermissionsRoute>(
  path: '/permissions',
)
class PermissionsRoute extends GoRouteData with _$PermissionsRoute {
  const PermissionsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Permissions();
  }
}

@TypedGoRoute<LanguageSettingsRoute>(
  path: '/language-settings',
)
class LanguageSettingsRoute extends GoRouteData with _$LanguageSettingsRoute {
  const LanguageSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LanguageSettingsPage();
  }
}

@TypedGoRoute<UserProfileRoute>(
  path: '/user-profile',
)
class UserProfileRoute extends GoRouteData with _$UserProfileRoute {
  const UserProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UserProfilePage();
  }
}

@TypedGoRoute<PaymentMethodsRoute>(
  path: '/payment-methods',
)
class PaymentMethodsRoute extends GoRouteData with _$PaymentMethodsRoute {
  const PaymentMethodsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const PaymentMethodsPage(),
      opaque: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _slideTransition(
          animation: animation,
          child: child,
          direction: SlideDirection.fromRight,
        );
      },
    );
  }
}

@TypedGoRoute<ChangePasswordRoute>(
  path: '/change-password',
)
class ChangePasswordRoute extends GoRouteData with _$ChangePasswordRoute {
  const ChangePasswordRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ChangePasswordPage(),
      opaque: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _slideTransition(
          animation: animation,
          child: child,
          direction: SlideDirection.fromRight,
        );
      },
    );
  }
}

@TypedGoRoute<TwoFactorAuthRoute>(
  path: '/two-factor-auth',
)
class TwoFactorAuthRoute extends GoRouteData with _$TwoFactorAuthRoute {
  const TwoFactorAuthRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const TwoFactorAuthPage(),
      opaque: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _slideTransition(
          animation: animation,
          child: child,
          direction: SlideDirection.fromRight,
        );
      },
    );
  }
}

@TypedGoRoute<StartPageRoute>(
  path: '/start',
)
class StartPageRoute extends GoRouteData with _$StartPageRoute {
  const StartPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const StartPage();
  }
}

@TypedGoRoute<PromoterHomeRoute>(
  path: '/promoter-home',
)
class PromoterHomeRoute extends GoRouteData with _$PromoterHomeRoute {
  const PromoterHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PromoterHomeScreen();
  }
}

@TypedGoRoute<AdvertiserHomeRoute>(
  path: '/advertiser-home',
)
class AdvertiserHomeRoute extends GoRouteData with _$AdvertiserHomeRoute {
  const AdvertiserHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdvertiserHomeScreen();
  }
}

@TypedGoRoute<AdvertiserSecuritySettingsRoute>(
  path: '/advertiser-security-settings',
)
class AdvertiserSecuritySettingsRoute extends GoRouteData
    with _$AdvertiserSecuritySettingsRoute {
  const AdvertiserSecuritySettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const SecuritySettingsPage(),
      opaque: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _slideTransition(
          animation: animation,
          child: child,
          direction: SlideDirection.fromRight,
        );
      },
    );
  }
}

@TypedGoRoute<CreateCampaignRoute>(
  path: '/create-campaign',
)
class CreateCampaignRoute extends GoRouteData with _$CreateCampaignRoute {
  const CreateCampaignRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const CreateCampaignPage(),
      opaque: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _slideTransition(
          animation: animation,
          child: child,
          direction: SlideDirection.fromRight,
        );
      },
    );
  }
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    routes: $appRoutes, // This will be generated
  );
}

class AppStartup extends ConsumerStatefulWidget {
  const AppStartup({super.key});

  @override
  ConsumerState<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends ConsumerState<AppStartup> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboardingDone') ?? false;
    // final onboardingDone = false; // Uncomment for testing onboarding

    if (!mounted) return;

    if (!onboardingDone) {
      const OnboardingRoute().go(context);
      return;
    }

    // Check authentication state using auth repository
    final authRepository = ref.read(authRepositoryProvider);
    model.User? user;
    try {
      user = await authRepository.getCurrentUser();
    } catch (e) {
      AppLogger.router.e('Error getting current user: $e');
    }

    if (!mounted) return;

    if (user != null) {
      // User is authenticated, route based on role
      if (user.role == model.UserRole.promoter) {
        const PromoterHomeRoute().go(context);
      } else if (user.role == model.UserRole.advertiser) {
        const AdvertiserHomeRoute().go(context);
      } else {
        // Unknown role, go to home
        const HomeRoute().go(context);
      }
    } else {
      // User not authenticated, go to login
      const LoginRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ============================================================================
// Reusable Route Transition Helpers
// ============================================================================

/// Slide direction for route transitions
enum SlideDirection {
  fromRight,
  fromLeft,
  fromBottom,
  fromTop,
}

/// Creates a slide transition for route animations
///
/// Usage:
/// ```dart
/// transitionsBuilder: (context, animation, secondaryAnimation, child) {
///   return _slideTransition(
///     animation: animation,
///     child: child,
///     direction: SlideDirection.fromRight,
///   );
/// }
/// ```
Widget _slideTransition({
  required Animation<double> animation,
  required Widget child,
  required SlideDirection direction,
  Curve curve = Curves.easeInOut,
}) {
  Offset begin;
  switch (direction) {
    case SlideDirection.fromRight:
      begin = const Offset(1.0, 0.0);
      break;
    case SlideDirection.fromLeft:
      begin = const Offset(-1.0, 0.0);
      break;
    case SlideDirection.fromBottom:
      begin = const Offset(0.0, 1.0);
      break;
    case SlideDirection.fromTop:
      begin = const Offset(0.0, -1.0);
      break;
  }

  const end = Offset.zero;
  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  final offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: child,
  );
}

/// Creates a fade transition for route animations
Widget _fadeTransition({
  required Animation<double> animation,
  required Widget child,
  Curve curve = Curves.easeInOut,
}) {
  final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
  return FadeTransition(
    opacity: curvedAnimation,
    child: child,
  );
}

/// Creates a scale transition for route animations
Widget _scaleTransition({
  required Animation<double> animation,
  required Widget child,
  Curve curve = Curves.easeInOut,
  Alignment alignment = Alignment.center,
}) {
  final tween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));
  final scaleAnimation = animation.drive(tween);

  return ScaleTransition(
    scale: scaleAnimation,
    alignment: alignment,
    child: child,
  );
}
