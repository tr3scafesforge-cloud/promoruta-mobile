class AppConfig {
  final String baseUrl;
  final String? configVersion;
  final String? versionCheckUrl;

  const AppConfig({
    required this.baseUrl,
    this.configVersion,
    this.versionCheckUrl,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      baseUrl: json['baseUrl'] as String,
      configVersion: json['configVersion'] as String?,
      versionCheckUrl: json['versionCheckUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      if (configVersion != null) 'configVersion': configVersion,
      if (versionCheckUrl != null) 'versionCheckUrl': versionCheckUrl,
    };
  }

  AppConfig copyWith({
    String? baseUrl,
    String? configVersion,
    String? versionCheckUrl,
  }) {
    return AppConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      configVersion: configVersion ?? this.configVersion,
      versionCheckUrl: versionCheckUrl ?? this.versionCheckUrl,
    );
  }
}