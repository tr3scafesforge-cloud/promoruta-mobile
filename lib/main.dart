import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

import 'app/routes/app_router.dart';
import 'core/theme.dart';
import 'shared/providers/providers.dart';

void main() {
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

    return MaterialApp.router(
      title: 'PromoRuta',
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
