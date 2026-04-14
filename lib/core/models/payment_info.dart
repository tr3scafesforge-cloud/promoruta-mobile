import 'package:promoruta/core/models/payment_status.dart';

class PaymentInfo {
  final PaymentStatus status;
  final String? checkoutUrl;
  final String? preferenceId;
  final String? gatewayId;

  const PaymentInfo({
    required this.status,
    this.checkoutUrl,
    this.preferenceId,
    this.gatewayId,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      status: json['payment_status'] != null
          ? PaymentStatus.fromString(json['payment_status'] as String)
          : json['status'] != null
              ? PaymentStatus.fromString(json['status'] as String)
              : PaymentStatus.pending,
      checkoutUrl: json['checkout_url'] as String?,
      preferenceId: json['preference_id'] as String?,
      gatewayId: json['gateway_id'] as String?,
    );
  }
}
