import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/routes/app_router.dart';
import 'core/constants/colors.dart';
import 'shared/providers/providers.dart';

void main() {
  runApp(
    // Wrap your app with ProviderScope
    const ProviderScope(
      child: PromorutaApp(),
    ),
  );
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
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeModeProvider);
        return MaterialApp.router(
          title: 'PromoRuta',
          locale: _locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
              // Customize specific colors for light theme
              outline: AppColors.grayLightStroke, // Custom outline color for light theme
              surfaceContainerHighest: AppColors.surface.withValues(alpha: 0.8),
            ),
            useMaterial3: true,
            fontFamily: GoogleFonts.robotoFlex().fontFamily,
            // You can customize specific colors here for light theme
            // scaffoldBackgroundColor: AppColors.background,
            // cardColor: AppColors.surface,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ).copyWith(
              // Customize specific colors for dark theme
              outline: AppColors.grayDarkStroke, // Custom outline color for dark theme
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimaryDark,
              surfaceContainerHighest: AppColors.surfaceDark.withValues(alpha: 0.8),
            ),
            useMaterial3: true,
            fontFamily: GoogleFonts.robotoFlex().fontFamily,
            // Additional dark theme customizations
            scaffoldBackgroundColor: AppColors.backgroundDark,
            cardColor: AppColors.surfaceDark,
          ),
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
