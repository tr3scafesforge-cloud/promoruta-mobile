import '../../core/models/version_info.dart';

abstract class UpdateCheckService {
  Future<VersionInfo?> checkForUpdates();
  Future<String> getCurrentAppVersion();
  bool isUpdateAvailable(String currentVersion, String remoteVersion);
}
