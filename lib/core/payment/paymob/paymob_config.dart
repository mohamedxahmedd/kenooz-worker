/// ──────────────────────────────────────────────────────────────────────────────
/// Paymob Configuration
/// ──────────────────────────────────────────────────────────────────────────────
/// A simple, immutable value-object that holds **all** merchant credentials
/// required by the Paymob Accept API.
///
/// Usage:
/// ```dart
/// const config = PaymobConfig(
///   apiKey: 'YOUR_API_KEY',
///   cardIntegrationId: '12345',
///   walletIntegrationId: '67890',
///   iframeId: '953042',
/// );
/// ```
///
/// > **Re-usability**: This class is completely decoupled from any Flutter
/// > widget or state-management library. Drop it into any Dart project.
class PaymobConfig {
  /// The API key found in your Paymob dashboard → Settings → Account Info.
  final String apiKey;

  /// Integration ID for **card** payments (online card integration).
  final String cardIntegrationId;

  /// Integration ID for **mobile-wallet** payments.
  final String walletIntegrationId;

  /// The iframe ID used when falling back to Paymob-hosted checkout.
  final String iframeId;

  /// Base URL for the Paymob Accept API.
  /// Defaults to the production endpoint.
  final String baseUrl;

  /// Currency code – defaults to `'EGP'`.
  final String currency;

  /// Payment-key expiration in seconds – defaults to 1 hour.
  final int expirationSeconds;

  const PaymobConfig({
    required this.apiKey,
    required this.cardIntegrationId,
    required this.walletIntegrationId,
    this.iframeId = '953042',
    this.baseUrl = 'https://accept.paymob.com/api',
    this.currency = 'EGP',
    this.expirationSeconds = 3600,
  });
}
