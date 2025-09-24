import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/onboarding_page_view.dart';
import 'presentation/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const PromorutaApp());
}

class PromorutaApp extends StatefulWidget {
  const PromorutaApp({super.key});

  @override
  State<PromorutaApp> createState() => _PromorutaAppState();
}

class _PromorutaAppState extends State<PromorutaApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // Get system locale
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final langCode = deviceLocale.languageCode;
      if (AppLocalizations.supportedLocales.any((locale) => locale.languageCode == langCode)) {
        _locale = Locale(langCode);
      } else {
        _locale = const Locale('en');
      }
    }
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return MaterialApp(
      title: 'PromoRuta',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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