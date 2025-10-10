import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/config.dart';

abstract class ConfigService {
  Future<AppConfig> getConfig();
  Future<void> refreshConfig();
}

class ConfigServiceImpl implements ConfigService {
  static const String _configKey = 'app_config';
  static const String _configVersionKey = 'config_version';
  static const String _assetsConfigPath = 'assets/config/app_config.json';

  final String? remoteConfigUrl;

  ConfigServiceImpl({this.remoteConfigUrl});

  @override
  Future<AppConfig> getConfig() async {
    try {
      // Try to get cached config first
      final cachedConfig = await _getCachedConfig();
      if (cachedConfig != null) {
        return cachedConfig;
      }

      // Try to fetch from remote
      final remoteConfig = await _fetchRemoteConfig();
      if (remoteConfig != null) {
        await _cacheConfig(remoteConfig);
        return remoteConfig;
      }
    } catch (e) {
      // Ignore errors and fall back to assets
    }

    // Fallback to assets
    return await _loadAssetsConfig();
  }

  @override
  Future<void> refreshConfig() async {
    try {
      final remoteConfig = await _fetchRemoteConfig();
      if (remoteConfig != null) {
        await _cacheConfig(remoteConfig);
      }
    } catch (e) {
      // If remote fails, keep current cached config
    }
  }

  Future<AppConfig?> _getCachedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);
    if (configJson != null) {
      try {
        final json = jsonDecode(configJson) as Map<String, dynamic>;
        return AppConfig.fromJson(json);
      } catch (e) {
        // Invalid cached config, remove it
        await prefs.remove(_configKey);
      }
    }
    return null;
  }

  Future<AppConfig?> _fetchRemoteConfig() async {
    if (remoteConfigUrl == null) return null;

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final uri = Uri.parse(remoteConfigUrl!);
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        return AppConfig.fromJson(json);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppConfig> _loadAssetsConfig() async {
    try {
      final jsonString = await rootBundle.loadString(_assetsConfigPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppConfig.fromJson(json);
    } catch (e) {
      // If assets config fails, use hardcoded fallback
      return const AppConfig(
        baseUrl: 'http://172.81.177.85/',
        configVersion: 'fallback',
      );
    }
  }

  Future<void> _cacheConfig(AppConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = jsonEncode(config.toJson());
    await prefs.setString(_configKey, configJson);
    if (config.configVersion != null) {
      await prefs.setString(_configVersionKey, config.configVersion!);
    }
  }
}