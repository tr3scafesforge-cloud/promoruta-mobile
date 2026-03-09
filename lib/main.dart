import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/constants/env.dart';
import 'package:promoruta/shared/services/push_notification_service.dart';
import 'package:promoruta/firebase_options.dart';

import 'app/routes/app_router.dart';
import 'shared/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: ".env");

  MapboxOptions.setAccessToken(Env.mapboxAccessToken);
  runApp(
    // Wrap your app with ProviderScope
    const ProviderScope(
      child: PromorutaApp(),
    ),
  );
}

class PromorutaApp extends ConsumerStatefulWidget {
  const PromorutaApp({super.key});

  @override
  ConsumerState<PromorutaApp> createState() => _PromorutaAppState();
}

class _PromorutaAppState extends ConsumerState<PromorutaApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(pushNotificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
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
