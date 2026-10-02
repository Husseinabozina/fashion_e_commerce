class SandboxPaymentSession {
  const SandboxPaymentSession({
    required this.attemptKey,
    required this.reference,
    required this.invoiceId,
    required this.checkoutUrl,
    required this.orderTotalEgp,
    this.ownerId,
  });

  final String attemptKey;
  final String reference;
  final int invoiceId;
  final Uri checkoutUrl;
  final double orderTotalEgp;
  final String? ownerId;
  static const double testAmount = 1;
  static const String testCurrency = 'KWD';

  SandboxPaymentReceipt get receipt => SandboxPaymentReceipt(invoiceId);
}

/// Client-verified virtual receipt. Never evidence of a real-money payment.
class SandboxPaymentReceipt {
  const SandboxPaymentReceipt(this.invoiceId);
  final int invoiceId;
}

enum SandboxPaymentStatus { paid, pending, declined, cancelled }
