// Shared Providers
//
// This file contains app-level providers and re-exports feature providers.
// Feature-specific providers are defined in their respective feature directories.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/theme.dart';
import 'package:promoruta/core/models/version_info.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/shared/services/notification_service.dart';
import 'package:promoruta/shared/services/overlay_notification_service.dart';
import 'package:promoruta/shared/services/route_service.dart';
import 'package:promoruta/shared/services/route_service_impl.dart';
import 'package:promoruta/shared/services/geocoding_service.dart';
import 'package:promoruta/shared/services/geocoding_service_impl.dart';
import 'package:promoruta/shared/services/update_check_service.dart';
import 'package:promoruta/shared/services/update_check_service_impl.dart';

// Re-export infrastructure providers (database, dio, connectivity, logger, config)
export 'infrastructure_providers.dart';

// Re-export auth providers from feature layer
export 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';

// Re-export feature providers
export 'package:promoruta/features/advertiser/campaign_management/presentation/providers/campaign_providers.dart';
export 'package:promoruta/features/promotor/presentation/providers/promoter_providers.dart';
export 'package:promoruta/features/profile/presentation/providers/profile_providers.dart';

// Import infrastructure and auth providers for use in this file
import 'package:promoruta/shared/providers/infrastructure_providers.dart';
import 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';

// ============ Shared Services ============

final routeServiceProvider = Provider<RouteService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return RouteServiceImpl(dio: dio, logger: logger);
});

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final logger = ref.watch(loggerProvider);
  return GeocodingServiceImpl(logger: logger);
});

// ============ Connectivity Status ============

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

// ============ Theme Providers ============

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final lightThemeProvider = Provider<ThemeData>((ref) {
  final authState = ref.watch(authStateProvider);
  final seedColor = authState.maybeWhen(
    data: (user) => user?.role == model.UserRole.promoter
        ? AppColors.primary
        : AppColors.primary,
    orElse: () => AppColors.primary,
  );
  return AppTheme.lightTheme(seedColor);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final authState = ref.watch(authStateProvider);
  final seedColor = authState.maybeWhen(
    data: (user) => user?.role == model.UserRole.promoter
        ? AppColors.primary
        : AppColors.primary,
    orElse: () => AppColors.primary,
  );
  return AppTheme.darkTheme(seedColor);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.light,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

// ============ Locale Provider ============

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString('languageCode');
    if (localeString != null) {
      state = Locale(localeString);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }
}

// ============ Notification Service ============

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return OverlayNotificationService(AppRouter.navigatorKey);
});

// ============ Update Check Service ============

final updateCheckServiceProvider = Provider<UpdateCheckService?>((ref) {
  final configAsync = ref.watch(configProvider);
  final logger = ref.watch(loggerProvider);

  return configAsync.maybeWhen(
    data: (config) {
      final versionCheckUrl = config.versionCheckUrl;
      if (versionCheckUrl == null || versionCheckUrl.isEmpty) {
        return null;
      }
      return UpdateCheckServiceImpl(
        versionCheckUrl: versionCheckUrl,
        logger: logger,
      );
    },
    orElse: () => null,
  );
});

final updateCheckProvider =
    FutureProvider.autoDispose<VersionInfo?>((ref) async {
  final service = ref.watch(updateCheckServiceProvider);
  if (service == null) {
    return null;
  }
  return await service.checkForUpdates();
});
