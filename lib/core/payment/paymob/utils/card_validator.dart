/// ──────────────────────────────────────────────────────────────────────────────
/// Card Validator — Luhn check + brand detection + field validation.
/// ──────────────────────────────────────────────────────────────────────────────
/// Stateless utility — no Flutter dependency, usable anywhere.
class CardValidator {
  CardValidator._();

  // ── Card brand detection ─────────────────────────────────────────────────

  static CardBrand detectBrand(String number) {
    final cleaned = number.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.isEmpty) return CardBrand.unknown;

    if (RegExp(r'^4').hasMatch(cleaned)) return CardBrand.visa;
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(cleaned)) {
      return CardBrand.mastercard;
    }
    if (RegExp(r'^(34|37)').hasMatch(cleaned)) return CardBrand.amex;
    if (RegExp(r'^(506[01]|6500)').hasMatch(cleaned)) return CardBrand.meeza;

    return CardBrand.unknown;
  }

  // ── Luhn algorithm ───────────────────────────────────────────────────────

  static bool isValidLuhn(String number) {
    final cleaned = number.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.isEmpty || !RegExp(r'^\d+$').hasMatch(cleaned)) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // ── Field validators (return null if valid, error string otherwise) ──────

  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Invalid card number length';
    }
    if (!isValidLuhn(cleaned)) return 'Invalid card number';
    return null;
  }

  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Expiry is required';
    final parts = value.replaceAll(' ', '').split('/');
    if (parts.length != 2) return 'Use MM/YY format';

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return 'Invalid date';
    if (month < 1 || month > 12) return 'Invalid month';

    final now = DateTime.now();
    final fullYear = year < 100 ? 2000 + year : year;
    final expiry = DateTime(fullYear, month + 1, 0); // Last day of month
    if (expiry.isBefore(now)) return 'Card has expired';

    return null;
  }

  static String? validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (value.length < 3 || value.length > 4) return 'Invalid CVV';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'CVV must be numeric';
    return null;
  }

  static String? validateCardHolder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cardholder name is required';
    }
    if (value.trim().length < 3) return 'Name is too short';
    return null;
  }

  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10) return 'Invalid phone number';
    return null;
  }

  // ── Formatting helpers ──────────────────────────────────────────────────

  /// Formats card number with spaces every 4 digits.
  static String formatCardNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Formats expiry as MM/YY.
  static String formatExpiry(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 3) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }
}

enum CardBrand { visa, mastercard, amex, meeza, unknown }
