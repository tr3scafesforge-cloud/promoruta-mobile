import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promoruta/features/auth/choose_role.dart';
import 'package:promoruta/features/auth/login.dart';
import 'package:promoruta/features/auth/onboarding_page_view.dart';
import 'package:promoruta/features/auth/permissions.dart';
import 'package:promoruta/features/auth/start_page.dart';
import 'package:promoruta/presentation/home_screen.dart';
import 'package:promoruta/presentation/promotor/promoter_home_screen.dart';
import 'package:promoruta/presentation/advertiser/advertiser_home_screen.dart';

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

  final String? role;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final roleParam = state.uri.queryParameters['role'] ?? 'unknown';
    return Login(role: roleParam);
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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: $appRoutes, // This will be generated
  );
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final prefs = await SharedPreferences.getInstance();
    // final onboardingDone = prefs.getBool('onboardingDone') ?? false;
    final onboardingDone = false; // todo: set to false for testing
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (mounted) {
      if (!onboardingDone) {
        const OnboardingRoute().go(context);
      } else if (isLoggedIn) {
        const HomeRoute().go(context);
      } else {
        // For now, go to home, but in real app, go to login
        const HomeRoute().go(context);
      }
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