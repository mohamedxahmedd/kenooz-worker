/// ──────────────────────────────────────────────────────────────────────────────
/// Payment Result — a unified result wrapper returned after any payment attempt.
/// ──────────────────────────────────────────────────────────────────────────────
enum PaymentStatus { success, failed, pending }

class PaymobPaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? orderId;
  final int? amountCents;
  final String? message;
  final String? redirectUrl; // For wallet 3D-secure / redirect flows
  final Map<String, dynamic>? rawResponse;

  const PaymobPaymentResult({
    required this.status,
    this.transactionId,
    this.orderId,
    this.amountCents,
    this.message,
    this.redirectUrl,
    this.rawResponse,
  });

  bool get isSuccess => status == PaymentStatus.success;
  bool get needsRedirect => redirectUrl != null && redirectUrl!.isNotEmpty;

  factory PaymobPaymentResult.success({
    required String transactionId,
    String? orderId,
    int? amountCents,
    Map<String, dynamic>? rawResponse,
  }) =>
      PaymobPaymentResult(
        status: PaymentStatus.success,
        transactionId: transactionId,
        orderId: orderId,
        amountCents: amountCents,
        message: 'Payment completed successfully',
        rawResponse: rawResponse,
      );

  factory PaymobPaymentResult.failed({
    String? message,
    Map<String, dynamic>? rawResponse,
  }) =>
      PaymobPaymentResult(
        status: PaymentStatus.failed,
        message: message ?? 'Payment failed',
        rawResponse: rawResponse,
      );

  factory PaymobPaymentResult.redirect({
    required String redirectUrl,
    Map<String, dynamic>? rawResponse,
  }) =>
      PaymobPaymentResult(
        status: PaymentStatus.pending,
        redirectUrl: redirectUrl,
        message: 'Redirecting to payment provider',
        rawResponse: rawResponse,
      );
}
