class VersionInfo {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final DateTime releaseDate;
  final String? releaseNotes;
  final String? minSupportedVersion;

  const VersionInfo({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.releaseDate,
    this.releaseNotes,
    this.minSupportedVersion,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as int,
      downloadUrl: json['downloadUrl'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      releaseNotes: json['releaseNotes'] as String?,
      minSupportedVersion: json['minSupportedVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildNumber': buildNumber,
      'downloadUrl': downloadUrl,
      'releaseDate': releaseDate.toIso8601String(),
      if (releaseNotes != null) 'releaseNotes': releaseNotes,
      if (minSupportedVersion != null)
        'minSupportedVersion': minSupportedVersion,
    };
  }

  /// Compares two semantic versions.
  /// Returns true if [other] is newer than [current].
  static bool isNewerVersion(String current, String other) {
    final currentParts = _parseVersion(current);
    final otherParts = _parseVersion(other);

    for (int i = 0; i < 3; i++) {
      if (otherParts[i] > currentParts[i]) {
        return true;
      } else if (otherParts[i] < currentParts[i]) {
        return false;
      }
    }

    return false;
  }

  static List<int> _parseVersion(String version) {
    final parts = version.split('.');
    return [
      parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
    ];
  }
}
