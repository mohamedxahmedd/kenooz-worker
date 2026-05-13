/// ──────────────────────────────────────────────────────────────────────────────
/// Card Data — card details for tokenised (non-iframe) payment.
/// ──────────────────────────────────────────────────────────────────────────────
class PaymobCardData {
  final String cardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

  const PaymobCardData({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  /// Strips spaces/dashes from card number.
  String get sanitizedNumber => cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

  Map<String, dynamic> toPaySource(
    String paymentToken, {
    bool saveCard = false,
  }) =>
      {
        'source': {
          'identifier': sanitizedNumber,
          'sourceholder_name': cardHolderName,
          'subtype': 'CARD',
          'expiry_month': expiryMonth,
          'expiry_year': expiryYear,
          'cvn': cvv,
        },
        'payment_token': paymentToken,
        // Ask Paymob to return a reusable card token in the response
        if (saveCard) 'save_card': true,
      };
}
