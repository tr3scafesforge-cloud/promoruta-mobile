import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/onboarding_page_view.dart';
import 'presentation/home_screen.dart';

void main() {
  runApp(const PromorutaApp());
}

class PromorutaApp extends StatelessWidget {
  const PromorutaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromoRuta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AppStartup(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingPageView(),
      },
    );
  }
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
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // For now, go to home, but in real app, go to login
        Navigator.of(context).pushReplacementNamed('/home');
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