import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promoruta/features/auth/choose_role.dart';
import 'package:promoruta/features/auth/login.dart';
import 'package:promoruta/features/auth/onboarding_page_view.dart';
import 'package:promoruta/features/auth/permissions.dart';
import 'package:promoruta/features/auth/start_page.dart';
import 'package:promoruta/presentation/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppStartup(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPageView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/choose-role',
        builder: (context, state) => const ChooseRole(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const Permissions(),
      ),
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartPage(),
      ),
    ],
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
    final onboardingDone = prefs.getBool('onboardingDone') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (mounted) {
      if (!onboardingDone) {
        context.go('/onboarding');
      } else if (isLoggedIn) {
        context.go('/home');
      } else {
        // For now, go to home, but in real app, go to login
        context.go('/home');
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