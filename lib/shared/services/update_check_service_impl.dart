import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/models/version_info.dart';
import 'update_check_service.dart';

class UpdateCheckServiceImpl implements UpdateCheckService {
  final String versionCheckUrl;
  final Logger? logger;

  static const Duration _timeout = Duration(seconds: 10);

  UpdateCheckServiceImpl({
    required this.versionCheckUrl,
    this.logger,
  });

  @override
  Future<VersionInfo?> checkForUpdates() async {
    try {
      final remoteVersion = await _fetchRemoteVersion();
      if (remoteVersion == null) {
        return null;
      }

      final currentVersion = await getCurrentAppVersion();
      if (isUpdateAvailable(currentVersion, remoteVersion.version)) {
        return remoteVersion;
      }

      return null;
    } catch (e) {
      logger?.e('Error checking for updates: $e');
      return null;
    }
  }

  @override
  Future<String> getCurrentAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  bool isUpdateAvailable(String currentVersion, String remoteVersion) {
    return VersionInfo.isNewerVersion(currentVersion, remoteVersion);
  }

  Future<VersionInfo?> _fetchRemoteVersion() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = _timeout;

      final uri = Uri.parse(versionCheckUrl);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(_timeout);

      if (response.statusCode == HttpStatus.ok) {
        final responseBody =
            await response.transform(utf8.decoder).join().timeout(_timeout);
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        return VersionInfo.fromJson(json);
      }

      logger?.w('Version check failed with status: ${response.statusCode}');
      return null;
    } on SocketException catch (e) {
      logger?.w('Network error during version check: $e');
      return null;
    } on HttpException catch (e) {
      logger?.w('HTTP error during version check: $e');
      return null;
    } on FormatException catch (e) {
      logger?.w('Invalid version.json format: $e');
      return null;
    } catch (e) {
      logger?.e('Unexpected error during version check: $e');
      return null;
    }
  }
}
