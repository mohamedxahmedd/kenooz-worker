import 'dart:convert';

/// Represents a saved card that can be reused for future payments.
///
/// The [token] is a Paymob-issued card token returned after a successful
/// payment.  It can only be used together with a fresh payment key that
/// was generated from the same merchant account — it does **not** contain
/// the full card number, CVV, or any other sensitive data.
class SavedCard {
  /// Unique local identifier (timestamp-based).
  final String id;

  /// Paymob card token — used as `source.identifier` with subtype `TOKEN`.
  final String token;

  /// Last 4 digits of the card number (e.g. "0007").
  final String last4;

  /// Card brand — "Visa", "Mastercard", "Meeza", etc.
  final String brand;

  /// Name on card.
  final String holderName;

  /// Expiry month (01–12).
  final String expiryMonth;

  /// Expiry year (2-digit, e.g. "28").
  final String expiryYear;

  /// Timestamp when this card was saved (for sorting / display).
  final DateTime savedAt;

  const SavedCard({
    required this.id,
    required this.token,
    required this.last4,
    required this.brand,
    required this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.savedAt,
  });

  /// Formatted expiry — "MM/YY".
  String get formattedExpiry => '$expiryMonth/$expiryYear';

  /// Masked display — "•••• •••• •••• 0007".
  String get maskedNumber => '•••• •••• •••• $last4';

  /// Whether this card has a real Paymob token (can be used for payment)
  /// vs. a pending placeholder (waiting for backend webhook).
  bool get hasRealToken => !token.startsWith('pending:');

  /// Whether this card is awaiting a real token from the backend.
  bool get isPending => token.startsWith('pending:');

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'last4': last4,
        'brand': brand,
        'holderName': holderName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedCard.fromJson(Map<String, dynamic> json) => SavedCard(
        id: json['id'] as String,
        token: json['token'] as String,
        last4: json['last4'] as String,
        brand: json['brand'] as String,
        holderName: json['holderName'] as String,
        expiryMonth: json['expiryMonth'] as String,
        expiryYear: json['expiryYear'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );

  String encode() => jsonEncode(toJson());

  factory SavedCard.decode(String source) =>
      SavedCard.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCard && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
