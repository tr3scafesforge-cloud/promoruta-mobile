class AppConfig {
  final String baseUrl;
  final String? configVersion;

  const AppConfig({
    required this.baseUrl,
    this.configVersion,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      baseUrl: json['baseUrl'] as String,
      configVersion: json['configVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      if (configVersion != null) 'configVersion': configVersion,
    };
  }

  AppConfig copyWith({
    String? baseUrl,
    String? configVersion,
  }) {
    return AppConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      configVersion: configVersion ?? this.configVersion,
    );
  }
}