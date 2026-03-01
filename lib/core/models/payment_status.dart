/// Payment status enumeration
enum PaymentStatus {
  pending,
  paid,
  refunded,
  processing,
  failed;

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
      case 'approved':
      case 'completed':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'processing':
        return PaymentStatus.processing;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.pending:
        return 'pending';
    }
  }
}
