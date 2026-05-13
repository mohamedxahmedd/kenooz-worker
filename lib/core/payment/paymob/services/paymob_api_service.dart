import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import '../models/billing_data.dart';
import '../models/card_data.dart';
import '../models/payment_result.dart';
import '../paymob_config.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Paymob API Service
/// ──────────────────────────────────────────────────────────────────────────────
/// A **stateless, reusable** HTTP client that wraps the four-step Paymob
/// Accept API flow:
///
///   1. Authenticate  →  auth token
///   2. Register order  →  order id
///   3. Request payment key  →  payment token
///   4. Pay  →  card / wallet
///
/// > **Portability**: Only depends on `dio` and the models in this package.
/// > Drop into any Dart/Flutter project — no BLoC / Provider dependency.
class PaymobApiService {
  final PaymobConfig _config;
  final Dio _dio;

  /// Cached auth token — reused for transaction status inquiries so we don't
  /// need to re-authenticate on every poll tick.
  String? _authToken;

  PaymobApiService({
    required PaymobConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = _config.baseUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1 — Authentication
  // ─────────────────────────────────────────────────────────────────────────

  /// Authenticates with Paymob and returns an **auth token**.
  Future<String> authenticate() async {
    developer.log(
      'Paymob auth → POST ${_config.baseUrl}/auth/tokens',
      name: 'PaymobAPI',
    );
    final response = await _dio.post(
      '/auth/tokens',
      data: {'api_key': _config.apiKey},
    );
    developer.log('Paymob auth → success', name: 'PaymobAPI');
    _authToken = response.data['token'] as String;
    return _authToken!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2 — Order Registration
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates an order on Paymob and returns the **order id**.
  ///
  /// [amountCents] must be in the smallest currency unit (piasters for EGP).
  Future<int> registerOrder({
    required String authToken,
    required int amountCents,
    String? merchantOrderId,
    List<Map<String, dynamic>>? items,
  }) async {
    final response = await _dio.post(
      '/ecommerce/orders',
      data: {
        'auth_token': authToken,
        'delivery_needed': false,
        'amount_cents': amountCents,
        'currency': _config.currency,
        if (merchantOrderId != null) 'merchant_order_id': merchantOrderId,
        'items': items ?? [],
      },
    );
    return response.data['id'] as int;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 3 — Payment Key
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a **payment key token** bound to the given order.
  ///
  /// [integrationId] should be the card or wallet integration id depending
  /// on which payment method is being used.
  Future<String> requestPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String integrationId,
    required PaymobBillingData billingData,
    bool saveCard = false,
  }) async {
    final response = await _dio.post(
      '/acceptance/payment_keys',
      data: {
        'auth_token': authToken,
        'amount_cents': amountCents,
        'expiration': _config.expirationSeconds,
        'order_id': orderId,
        'billing_data': billingData.toJson(),
        'currency': _config.currency,
        'integration_id': int.parse(integrationId),
        'lock_order_when_paid': true,
        if (saveCard) 'save_card': true,
      },
    );
    return response.data['token'] as String;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 4a — Pay with Card (tokenised / non-iframe)
  // ─────────────────────────────────────────────────────────────────────────

  /// Sends card details directly to Paymob and returns a [PaymobPaymentResult].
  ///
  /// If 3D-Secure is required the result will carry a [redirectUrl].
  Future<PaymobPaymentResult> payWithCard({
    required String paymentToken,
    required PaymobCardData card,
    bool saveCard = false,
  }) async {
    try {
      final response = await _dio.post(
        '/acceptance/payments/pay',
        data: card.toPaySource(paymentToken, saveCard: saveCard),
      );

      final data = response.data as Map<String, dynamic>;

      developer.log(
        'Paymob payCard response → '
        'success=${data['success']}, '
        'is_success=${data['is_success']}, '
        'pending=${data['pending']}, '
        'txn_response_code=${data['txn_response_code']}, '
        'data.message=${data['data']?['message']}, '
        'redirect_url=${data['redirect_url']}, '
        'id=${data['id']}, '
        'token=${data['token'] != null}, '
        'source_data=${data['source_data']}, '
        'keys=${data.keys.toList()}',
        name: 'PaymobAPI',
      );

      // Check for 3D-Secure redirect (Paymob uses different keys)
      final redirectUrl = (data['redirect_url'] as String?) ??
          (data['redirection_url'] as String?) ??
          (data['iframe_redirection_url'] as String?);
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        developer.log(
          'Paymob 3DS redirect → $redirectUrl',
          name: 'PaymobAPI',
        );
        return PaymobPaymentResult.redirect(
          redirectUrl: redirectUrl,
          rawResponse: data,
        );
      }

      // Check transaction success
      final isSuccess = data['success'] == true ||
          data['is_success'] == true ||
          data['pending'] == true;

      if (isSuccess) {
        return PaymobPaymentResult.success(
          transactionId: '${data['id'] ?? ''}',
          orderId: '${data['order']?['id'] ?? ''}',
          amountCents: data['amount_cents'] as int?,
          rawResponse: data,
        );
      }

      return PaymobPaymentResult.failed(
        message: _extractErrorMessage(data),
        rawResponse: data,
      );
    } on DioException catch (e) {
      return PaymobPaymentResult.failed(
        message: _parseDioError(e),
        rawResponse: e.response?.data is Map
            ? e.response?.data as Map<String, dynamic>
            : null,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 4a′ — Pay with Saved Card Token
  // ─────────────────────────────────────────────────────────────────────────

  /// Pays using a previously saved card token (Paymob `TOKEN` subtype).
  ///
  /// The [cardToken] is the reuse token returned by Paymob after a successful
  /// first-time card payment.  It requires a fresh [paymentToken] from
  /// [requestPaymentKey] and the card's [cvv] (Paymob mandates CVV even for
  /// saved tokens).
  Future<PaymobPaymentResult> payWithSavedCard({
    required String paymentToken,
    required String cardToken,
    required String cvv,
  }) async {
    try {
      developer.log(
        'Paymob payToken → token: ${cardToken.substring(0, 8)}…',
        name: 'PaymobAPI',
      );

      final response = await _dio.post(
        '/acceptance/payments/pay',
        data: {
          'source': {
            'identifier': cardToken,
            'subtype': 'TOKEN',
            'cvn': cvv,
          },
          'payment_token': paymentToken,
        },
      );

      final data = response.data as Map<String, dynamic>;

      developer.log(
        'Paymob payToken response → '
        'success=${data['success']}, '
        'is_success=${data['is_success']}, '
        'pending=${data['pending']}, '
        'txn_response_code=${data['txn_response_code']}, '
        'redirect_url=${data['redirect_url']}, '
        'id=${data['id']}',
        name: 'PaymobAPI',
      );

      // Token payments can still trigger 3DS
      final redirectUrl = (data['redirect_url'] as String?) ??
          (data['redirection_url'] as String?) ??
          (data['iframe_redirection_url'] as String?);
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        return PaymobPaymentResult.redirect(
          redirectUrl: redirectUrl,
          rawResponse: data,
        );
      }

      final isSuccess = data['success'] == true ||
          data['is_success'] == true ||
          data['pending'] == true;

      if (isSuccess) {
        return PaymobPaymentResult.success(
          transactionId: '${data['id'] ?? ''}',
          orderId: '${data['order']?['id'] ?? ''}',
          amountCents: data['amount_cents'] as int?,
          rawResponse: data,
        );
      }

      return PaymobPaymentResult.failed(
        message: _extractErrorMessage(data),
        rawResponse: data,
      );
    } on DioException catch (e) {
      return PaymobPaymentResult.failed(
        message: _parseDioError(e),
        rawResponse: e.response?.data is Map
            ? e.response?.data as Map<String, dynamic>
            : null,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 4b — Pay with Wallet
  // ─────────────────────────────────────────────────────────────────────────

  /// Initiates a mobile-wallet payment and returns a result with [redirectUrl].
  ///
  /// The caller must open the redirect URL in a WebView so the customer
  /// can approve the payment inside their wallet app.
  Future<PaymobPaymentResult> payWithWallet({
    required String paymentToken,
    required String mobileNumber,
  }) async {
    try {
      // Paymob Accept API expects the raw 11-digit Egyptian number
      final formattedNumber = mobileNumber.trim();

      developer.log(
        'Paymob payWallet → number: $formattedNumber',
        name: 'PaymobAPI',
      );

      final response = await _dio.post(
        '/acceptance/payments/pay',
        data: {
          'source': {
            'identifier': formattedNumber,
            'subtype': 'WALLET',
          },
          'payment_token': paymentToken,
        },
      );

      final data = response.data as Map<String, dynamic>;

      developer.log(
        'Paymob payWallet response → '
        'success=${data['success']}, '
        'is_success=${data['is_success']}, '
        'pending=${data['pending']}, '
        'data.message=${data['data']?['message']}, '
        'redirect_url=${data['redirect_url']}, '
        'id=${data['id']}',
        name: 'PaymobAPI',
      );

      final redirectUrl = data['redirect_url'] as String?;

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        return PaymobPaymentResult.redirect(
          redirectUrl: redirectUrl,
          rawResponse: data,
        );
      }

      // Some wallets may respond with instant success
      final isSuccess = data['success'] == true || data['is_success'] == true;
      if (isSuccess) {
        return PaymobPaymentResult.success(
          transactionId: '${data['id'] ?? ''}',
          orderId: '${data['order']?['id'] ?? ''}',
          amountCents: data['amount_cents'] as int?,
          rawResponse: data,
        );
      }

      return PaymobPaymentResult.failed(
        message: _extractErrorMessage(data),
        rawResponse: data,
      );
    } on DioException catch (e) {
      return PaymobPaymentResult.failed(
        message: _parseDioError(e),
        rawResponse: e.response?.data is Map
            ? e.response?.data as Map<String, dynamic>
            : null,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Iframe URL builder (fallback)
  // ─────────────────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────────
  // Transaction status inquiry
  // ─────────────────────────────────────────────────────────────────────────

  /// Queries Paymob for the current status of a transaction.
  ///
  /// Returns a map with at minimum:
  ///   `success` (bool), `pending` (bool), `id` (int)
  ///
  /// The endpoint requires an auth token. We use the one cached during
  /// [preparePayment]. If it has expired (401), we re-authenticate once and
  /// retry automatically.
  Future<Map<String, dynamic>> checkTransactionStatus(int transactionId) async {
    // Ensure we have a token (will authenticate if called before preparePayment)
    final token = _authToken ?? await authenticate();

    developer.log(
      'Paymob checkTxn → GET /acceptance/transactions/$transactionId',
      name: 'PaymobAPI',
    );

    try {
      // Paymob Accept API: pass auth token as query parameter
      final response = await _dio.get(
        '/acceptance/transactions/$transactionId',
        queryParameters: {'token': token},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // If 401 with query param, re-authenticate and try Bearer header
      if (e.response?.statusCode == 401) {
        developer.log(
          'Paymob checkTxn → 401 with query token, re-auth + Bearer',
          name: 'PaymobAPI',
        );
        final freshToken = await authenticate();
        try {
          final response = await _dio.get(
            '/acceptance/transactions/$transactionId',
            queryParameters: {'token': freshToken},
          );
          return response.data as Map<String, dynamic>;
        } on DioException {
          // Last resort: try Bearer header
          final response = await _dio.get(
            '/acceptance/transactions/$transactionId',
            options: Options(
              headers: {'Authorization': 'Bearer $freshToken'},
            ),
          );
          return response.data as Map<String, dynamic>;
        }
      }
      rethrow;
    }
  }

  /// Returns the full iframe URL for Paymob-hosted checkout.
  String getIframeUrl(String paymentToken) =>
      'https://accept.paymob.com/api/acceptance/iframes/'
      '${_config.iframeId}?payment_token=$paymentToken';

  // ─────────────────────────────────────────────────────────────────────────
  // High-level convenience — full flow in one call
  // ─────────────────────────────────────────────────────────────────────────

  /// Runs the complete **auth → order → payment-key** pipeline and returns
  /// the payment token ready for the pay step.
  ///
  /// This is the method you'll call most often from UI code.
  Future<PaymentKeyData> preparePayment({
    required int amountCents,
    required PaymobBillingData billingData,
    required PaymentMethod method,
    String? merchantOrderId,
    List<Map<String, dynamic>>? items,
    bool saveCard = false,
  }) async {
    // 1. Auth
    final authToken = await authenticate();

    // 2. Order
    final orderId = await registerOrder(
      authToken: authToken,
      amountCents: amountCents,
      merchantOrderId: merchantOrderId,
      items: items,
    );

    // 3. Payment key
    final integrationId = method == PaymentMethod.card
        ? _config.cardIntegrationId
        : _config.walletIntegrationId;

    final paymentToken = await requestPaymentKey(
      authToken: authToken,
      orderId: orderId,
      amountCents: amountCents,
      integrationId: integrationId,
      billingData: billingData,
      saveCard: saveCard,
    );

    return PaymentKeyData(
      authToken: authToken,
      orderId: orderId,
      paymentToken: paymentToken,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _extractErrorMessage(Map<String, dynamic> data) {
    developer.log(
      'Paymob error extraction → raw keys: ${data.keys.toList()}, '
      'txn_response_code=${data['txn_response_code']}, '
      'data.message=${data['data']?['message']}, '
      'detail=${data['detail']}, '
      'message=${data['message']}',
      name: 'PaymobAPI',
    );

    // Paymob returns errors in different shapes
    if (data.containsKey('data') && data['data'] is Map) {
      final inner = data['data'] as Map;
      if (inner.containsKey('message')) return inner['message'].toString();
    }
    if (data.containsKey('detail')) return data['detail'].toString();
    if (data.containsKey('message')) return data['message'].toString();

    // Validation errors: {"source": ["error message"]} or {"source": {"subtype": [...]}}
    if (data.containsKey('source')) {
      final src = data['source'];
      if (src is List && src.isNotEmpty) return src.first.toString();
      if (src is Map) return src.values.expand((v) => v is List ? v : [v]).join(', ');
      return src.toString();
    }

    // Check for txn_response_code-based messages
    final txnCode = data['txn_response_code']?.toString();
    if (txnCode != null && txnCode.isNotEmpty && txnCode != 'null') {
      return 'Transaction declined (code: $txnCode)';
    }

    return 'Payment was declined';
  }

  String _parseDioError(DioException e) {
    developer.log(
      'Paymob DioException → status=${e.response?.statusCode}, '
      'body=${e.response?.data}',
      name: 'PaymobAPI',
    );
    if (e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      return _extractErrorMessage(data);
    }
    return e.message ?? 'Network error — please try again';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting types
// ─────────────────────────────────────────────────────────────────────────────

enum PaymentMethod { card, wallet }

/// Data returned after the three-step preparation pipeline.
class PaymentKeyData {
  final String authToken;
  final int orderId;
  final String paymentToken;

  const PaymentKeyData({
    required this.authToken,
    required this.orderId,
    required this.paymentToken,
  });
}
