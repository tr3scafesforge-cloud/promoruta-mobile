class MercadoPagoAccountStatus {
  final bool connected;
  final String? userId;
  final String? username;
  final DateTime? tokenExpiresAt;

  const MercadoPagoAccountStatus({
    required this.connected,
    this.userId,
    this.username,
    this.tokenExpiresAt,
  });

  factory MercadoPagoAccountStatus.fromJson(Map<String, dynamic> json) {
    final account = json['mercado_pago_account'] as Map<String, dynamic>?;
    return MercadoPagoAccountStatus(
      connected: json['connected'] as bool? ?? false,
      userId: account?['user_id'] as String?,
      username: account?['username'] as String?,
      tokenExpiresAt: account?['token_expires_at'] != null
          ? DateTime.tryParse(account!['token_expires_at'] as String)
          : null,
    );
  }
}

class MercadoPagoAuthorizeUrlData {
  final String authorizeUrl;
  final String? state;
  final int? stateExpiresIn;
  final String? redirectUri;

  const MercadoPagoAuthorizeUrlData({
    required this.authorizeUrl,
    this.state,
    this.stateExpiresIn,
    this.redirectUri,
  });

  factory MercadoPagoAuthorizeUrlData.fromJson(Map<String, dynamic> json) {
    return MercadoPagoAuthorizeUrlData(
      authorizeUrl: json['authorize_url'] as String,
      state: json['state'] as String?,
      stateExpiresIn: json['state_expires_in'] as int?,
      redirectUri: json['redirect_uri'] as String?,
    );
  }
}
