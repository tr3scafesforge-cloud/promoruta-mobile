import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/advertiser/presentation/pages/advertiser_home_screen.dart';
import 'package:promoruta/features/profile/presentation/pages/user_profile_page.dart';
import 'package:promoruta/features/promotor/presentation/pages/promoter_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/features/auth/presentation/pages/choose_role_page.dart';
import 'package:promoruta/features/auth/presentation/pages/login_page.dart';
import 'package:promoruta/features/auth/presentation/pages/onboarding_page.dart';
import 'package:promoruta/features/auth/presentation/pages/permissions_page.dart';
import 'package:promoruta/features/auth/presentation/pages/start_page.dart';
import 'package:promoruta/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:promoruta/features/auth/presentation/pages/verify_reset_code_page.dart';
import 'package:promoruta/features/auth/presentation/pages/sign_up_page.dart';
import 'package:promoruta/features/auth/presentation/pages/verify_email_page.dart';
import 'package:promoruta/presentation/home_screen.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_security_settings_page.dart';
import 'package:promoruta/presentation/advertiser/pages/language_settings_page.dart';
import 'package:promoruta/presentation/advertiser/pages/payment_methods_page.dart';
import 'package:promoruta/presentation/advertiser/pages/change_password_page.dart';
import 'package:promoruta/presentation/advertiser/pages/two_factor_auth_page.dart';
import 'package:promoruta/presentation/advertiser/pages/two_factor_setup_page.dart';
import 'package:promoruta/presentation/advertiser/pages/recovery_codes_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_security_settings_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_two_factor_auth_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_two_factor_setup_page.dart';
import 'package:promoruta/features/advertiser/campaign_creation/presentation/pages/create_campaign_page.dart';
import 'package:promoruta/features/advertiser/presentation/pages/campaign_details_page.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/app/routes/route_guards.dart';
import 'package:promoruta/app/routes/auth_notifier.dart';

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

@TypedGoRoute<SignUpRoute>(
  path: '/sign-up',
)
class SignUpRoute extends GoRouteData with _$SignUpRoute {
  const SignUpRoute({this.role});

  final model.UserRole? role;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final roleParam = state.uri.queryParameters['role'];
    final userRole = roleParam != null
        ? model.UserRole.fromString(roleParam)
        : role;
    return SignUpPage(role: userRole);
  }
}

@TypedGoRoute<VerifyEmailRoute>(
  path: '/verify-email',
)
class VerifyEmailRoute extends GoRouteData with _$VerifyEmailRoute {
  const VerifyEmailRoute({required this.email, this.role});

  final String email;
  final model.UserRole? role;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final roleParam = state.uri.queryParameters['role'];
    final userRole = roleParam != null
        ? model.UserRole.fromString(roleParam)
        : role;
    return VerifyEmailPage(email: email, role: userRole);
  }
}

@TypedGoRoute<ForgotPasswordRoute>(
  path: '/forgot-password',
)
class ForgotPasswordRoute extends GoRouteData with _$ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordPage();
  }
}

@TypedGoRoute<VerifyResetCodeRoute>(
  path: '/verify-reset-code',
)
class VerifyResetCodeRoute extends GoRouteData with _$VerifyResetCodeRoute {
  const VerifyResetCodeRoute({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return VerifyResetCodePage(email: email);
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

@TypedGoRoute<Advertiser2FASetupRoute>(
  path: '/advertiser-2fa-setup',
)
class Advertiser2FASetupRoute extends GoRouteData
    with _$Advertiser2FASetupRoute {
  const Advertiser2FASetupRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const TwoFactorSetupPage(),
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

@TypedGoRoute<AdvertiserRecoveryCodesRoute>(
  path: '/advertiser-recovery-codes',
)
class AdvertiserRecoveryCodesRoute extends GoRouteData
    with _$AdvertiserRecoveryCodesRoute {
  const AdvertiserRecoveryCodesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const RecoveryCodesPage(),
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

@TypedGoRoute<CampaignDetailsRoute>(
  path: '/campaign-details/:campaignId',
)
class CampaignDetailsRoute extends GoRouteData with _$CampaignDetailsRoute {
  final String campaignId;

  const CampaignDetailsRoute({required this.campaignId});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: CampaignDetailsPage(campaignId: campaignId),
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

@TypedGoRoute<PromoterSecuritySettingsRoute>(
  path: '/promoter-security-settings',
)
class PromoterSecuritySettingsRoute extends GoRouteData
    with _$PromoterSecuritySettingsRoute {
  const PromoterSecuritySettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const PromoterSecuritySettingsPage(),
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

@TypedGoRoute<PromoterTwoFactorAuthRoute>(
  path: '/promoter-two-factor-auth',
)
class PromoterTwoFactorAuthRoute extends GoRouteData
    with _$PromoterTwoFactorAuthRoute {
  const PromoterTwoFactorAuthRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const PromoterTwoFactorAuthPage(),
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

@TypedGoRoute<Promoter2FASetupRoute>(
  path: '/promoter-2fa-setup',
)
class Promoter2FASetupRoute extends GoRouteData
    with _$Promoter2FASetupRoute {
  const Promoter2FASetupRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const PromoterTwoFactorSetupPage(),
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

@TypedGoRoute<PromoterRecoveryCodesRoute>(
  path: '/promoter-recovery-codes',
)
class PromoterRecoveryCodesRoute extends GoRouteData
    with _$PromoterRecoveryCodesRoute {
  const PromoterRecoveryCodesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const RecoveryCodesPage(),
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

  static GoRouter createRouter(GoRouterAuthNotifier authNotifier) {
    return GoRouter(
      initialLocation: '/',
      navigatorKey: navigatorKey,
      routes: $appRoutes,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final user = authNotifier.user;
        final path = state.uri.path;

        // Allow startup route to handle its own navigation
        if (path == '/') {
          return null;
        }

        final guard = RouteGuards.getGuard(path);

        // Public routes - allow access
        if (guard != null && !guard.requiresAuth) {
          return null;
        }

        // Protected routes - check role-based access only if user is loaded
        if (guard != null && guard.requiresAuth && user != null) {
          // Check role-based access
          if (!guard.canAccess(user.role)) {
            // User doesn't have required role
            AppLogger.router.w('Access denied to $path: role ${user.role} not allowed');

            // Redirect to appropriate home based on user's role
            if (user.role == model.UserRole.promoter) {
              return '/promoter-home';
            } else if (user.role == model.UserRole.advertiser) {
              return '/advertiser-home';
            }
            return '/home';
          }
        }

        // Allow access if user is null (let AppStartup handle auth)
        // or if user has the required role
        return null;
      },
    );
  }
}

// Auth notifier provider
final goRouterAuthNotifierProvider = Provider<GoRouterAuthNotifier>((ref) {
  return GoRouterAuthNotifier(ref);
});

// Router provider that provides the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(goRouterAuthNotifierProvider);
  return AppRouter.createRouter(authNotifier);
});

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
