import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/constants/env.dart';

import 'app/routes/app_router.dart';
import 'shared/providers/providers.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  MapboxOptions.setAccessToken(Env.mapboxAccessToken);
  runApp(
    // Wrap your app with ProviderScope
    const ProviderScope(
      child: PromorutaApp(),
    ),
  );
}

class PromorutaApp extends ConsumerWidget {
  const PromorutaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PromoRuta',
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
