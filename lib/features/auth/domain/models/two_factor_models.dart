/// Model for 2FA enable response (QR code and secret)
class TwoFactorEnableResponse {
  final String secret;
  final String qrCodeSvg;
  final String message;

  const TwoFactorEnableResponse({
    required this.secret,
    required this.qrCodeSvg,
    required this.message,
  });

  factory TwoFactorEnableResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorEnableResponse(
      secret: json['secret'] as String,
      qrCodeSvg: json['qr_code_svg'] as String,
      message: json['message'] as String,
    );
  }
}

/// Model for 2FA confirmation response (with recovery codes)
class TwoFactorConfirmResponse {
  final String message;
  final List<String> recoveryCodes;

  const TwoFactorConfirmResponse({
    required this.message,
    required this.recoveryCodes,
  });

  factory TwoFactorConfirmResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorConfirmResponse(
      message: json['message'] as String,
      recoveryCodes: (json['recovery_codes'] as List)
          .map((code) => code as String)
          .toList(),
    );
  }
}

/// Model for recovery codes response
class RecoveryCodesResponse {
  final List<String> recoveryCodes;
  final String? message;

  const RecoveryCodesResponse({
    required this.recoveryCodes,
    this.message,
  });

  factory RecoveryCodesResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryCodesResponse(
      recoveryCodes: (json['recovery_codes'] as List)
          .map((code) => code as String)
          .toList(),
      message: json['message'] as String?,
    );
  }
}

/// Model for login response that requires 2FA
class TwoFactorRequiredResponse {
  final bool requires2fa;
  final String message;
  final String email;

  const TwoFactorRequiredResponse({
    required this.requires2fa,
    required this.message,
    required this.email,
  });

  factory TwoFactorRequiredResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorRequiredResponse(
      requires2fa: json['requires_2fa'] as bool,
      message: json['message'] as String,
      email: json['email'] as String,
    );
  }
}

/// Exception thrown when 2FA is required during login
class TwoFactorRequiredException implements Exception {
  final String email;
  final String message;

  TwoFactorRequiredException({
    required this.email,
    required this.message,
  });

  @override
  String toString() => message;
}
