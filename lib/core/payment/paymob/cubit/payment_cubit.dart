import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/payment/paymob/models/payment_result.dart';
import '../models/billing_data.dart';
import '../models/card_data.dart';
import '../models/saved_card.dart';
import '../services/paymob_api_service.dart';
import '../services/saved_cards_service.dart';
import 'payment_state.dart';

/// Tiny helper so we can chain `.nullIfEmpty` on nullable strings.
extension _NullIfEmpty on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

/// ──────────────────────────────────────────────────────────────────────────────
/// Payment Cubit
/// ──────────────────────────────────────────────────────────────────────────────
/// Orchestrates the full Paymob payment lifecycle.
///
/// Typical usage from the UI:
///
/// ```dart
/// // 1. Prepare
/// cubit.preparePayment(amountCents: 5000, billingData: billing, method: PaymentMethod.card);
///
/// // 2. Listen for PaymentReady, then submit card
/// cubit.submitCardPayment(cardData);
///
/// // 3. Listen for PaymentSuccess / PaymentFailed / PaymentRedirect
/// ```
class PaymobPaymentCubit extends Cubit<PaymobPaymentState> {
  final PaymobApiService _apiService;

  PaymobPaymentCubit({required PaymobApiService apiService})
      : _apiService = apiService,
        super(const PaymentInitial());

  // Cached from the preparation step
  PaymentKeyData? _keyData;

  /// The current payment token, if available.
  String? get paymentToken => _keyData?.paymentToken;

  // Background polling for redirect flows
  Timer? _pollTimer;
  int? _pendingTransactionId;

  // ── Cached card token from the initial payWithCard response ──────────────
  // The Paymob transaction inquiry endpoint does NOT return the card reuse
  // token.  It is only present in the initial POST /acceptance/payments/pay
  // response.  We cache it here so we can still save the card after 3DS.
  String? _pendingCardToken;
  Map<String, dynamic>? _pendingSourceData;

  /// The card reuse token extracted from the initial pay response (before 3DS).
  String? get pendingCardToken => _pendingCardToken;

  /// The source_data from the initial pay response (contains pan, type, etc.).
  Map<String, dynamic>? get pendingSourceData => _pendingSourceData;

  // ─────────────────────────────────────────────────────────────────────────
  // Prepare (auth → order → payment key)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> preparePayment({
    required int amountCents,
    required PaymobBillingData billingData,
    required PaymentMethod method,
    String? merchantOrderId,
    List<Map<String, dynamic>>? items,
    bool saveCard = false,
  }) async {
    try {
      emit(const PaymentPreparing(message: 'Authenticating...'));

      _keyData = await _apiService.preparePayment(
        amountCents: amountCents,
        billingData: billingData,
        method: method,
        merchantOrderId: merchantOrderId,
        items: items,
        saveCard: saveCard,
      );

      emit(PaymentReady(
        paymentToken: _keyData!.paymentToken,
        orderId: _keyData!.orderId,
      ));
    } catch (e) {
      emit(PaymentFailed(message: _friendlyError(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pay with card (native UI — no iframe)
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether the user wants to save the card for future use.
  bool _saveCardRequested = false;

  Future<void> submitCardPayment(
    PaymobCardData card, {
    bool saveCard = false,
  }) async {
    if (_keyData == null) {
      emit(const PaymentFailed(message: 'Payment not prepared yet'));
      return;
    }

    _saveCardRequested = saveCard;

    try {
      emit(const PaymentProcessing());

      final result = await _apiService.payWithCard(
        paymentToken: _keyData!.paymentToken,
        card: card,
        saveCard: saveCard,
      );

      // ── Cache the card reuse token from the initial response ────────
      // Paymob may return the token here if `save_card: true` was sent.
      // The response may use a nested `source_data` map OR flat dotted
      // keys like `source_data.pan`, `source_data.type`.
      final raw = result.rawResponse;
      if (raw != null) {
        _pendingCardToken = raw['token']?.toString().nullIfEmpty ??
            raw['card_token']?.toString().nullIfEmpty;

        // Handle nested source_data map
        final nestedSource = raw['source_data'];
        if (nestedSource is Map<String, dynamic>) {
          _pendingSourceData = nestedSource;
          _pendingCardToken ??= nestedSource['token']?.toString().nullIfEmpty;
        } else {
          // Handle flat dotted keys: source_data.pan, source_data.type, etc.
          _pendingSourceData = {
            if (raw['source_data.pan'] != null) 'pan': raw['source_data.pan'],
            if (raw['source_data.type'] != null) 'type': raw['source_data.type'],
            if (raw['source_data.sub_type'] != null) 'sub_type': raw['source_data.sub_type'],
          };
          if (_pendingSourceData!.isEmpty) _pendingSourceData = null;
        }

        developer.log(
          'payWithCard → cached token=${_pendingCardToken != null}, '
          'source_data=${_pendingSourceData}, '
          'all_keys=${raw.keys.toList()}',
          name: 'PaymobCubit',
        );
      }

      if (result.isSuccess) {
        emit(PaymentSuccess(result: result));
      } else if (result.needsRedirect) {
        final txnId = result.rawResponse?['id'] as int?;
        emit(PaymentRedirect(
          redirectUrl: result.redirectUrl!,
          transactionId: txnId,
        ));
      } else {
        emit(PaymentFailed(message: result.message ?? 'Payment declined'));
      }
    } catch (e) {
      emit(PaymentFailed(message: _friendlyError(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pay with saved card token
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> submitSavedCardPayment({
    required SavedCard savedCard,
    required String cvv,
  }) async {
    if (_keyData == null) {
      emit(const PaymentFailed(message: 'Payment not prepared yet'));
      return;
    }

    try {
      emit(const PaymentProcessing());

      final result = await _apiService.payWithSavedCard(
        paymentToken: _keyData!.paymentToken,
        cardToken: savedCard.token,
        cvv: cvv,
      );

      if (result.isSuccess) {
        emit(PaymentSuccess(result: result));
      } else if (result.needsRedirect) {
        final txnId = result.rawResponse?['id'] as int?;
        emit(PaymentRedirect(
          redirectUrl: result.redirectUrl!,
          transactionId: txnId,
        ));
      } else {
        emit(PaymentFailed(message: result.message ?? 'Payment declined'));
      }
    } catch (e) {
      emit(PaymentFailed(message: _friendlyError(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Save card helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts a [SavedCard] from a successful payment response.
  ///
  /// Returns `null` if the response doesn't contain a reusable card token
  /// (e.g. wallet payments).
  static SavedCard? extractSavedCard(PaymobPaymentResult result) {
    final raw = result.rawResponse;
    if (raw == null) return null;

    // Paymob may use a nested `source_data` map OR flat dotted keys.
    final nestedSource = raw['source_data'];
    final Map<String, dynamic>? sourceData =
        nestedSource is Map<String, dynamic>
            ? nestedSource
            : {
                if (raw['source_data.pan'] != null) 'pan': raw['source_data.pan'],
                if (raw['source_data.type'] != null) 'type': raw['source_data.type'],
                if (raw['source_data.sub_type'] != null) 'sub_type': raw['source_data.sub_type'],
              };

    // Check all possible locations for the card reuse token
    final token = (raw['token']?.toString().nullIfEmpty) ??
        (sourceData?['token']?.toString().nullIfEmpty) ??
        (raw['card_token']?.toString().nullIfEmpty);

    if (token == null) {
      developer.log(
        'extractSavedCard → no reuse token found in response keys: ${raw.keys.toList()}',
        name: 'PaymobCubit',
      );
      return null;
    }

    developer.log(
      'extractSavedCard → found token: ${token.substring(0, 8)}…',
      name: 'PaymobCubit',
    );

    final pan = sourceData?['pan']?.toString() ?? '';
    final last4 = pan.length >= 4 ? pan.substring(pan.length - 4) : pan;
    final brand = sourceData?['sub_type']?.toString() ??
        sourceData?['type']?.toString() ??
        'Card';

    return SavedCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      token: token,
      last4: last4,
      brand: brand,
      holderName: '', // filled by caller
      expiryMonth: '',
      expiryYear: '',
      savedAt: DateTime.now(),
    );
  }

  /// Convenience: save a card from a successful result.
  ///
  /// **Token sources (checked in order):**
  /// 1. `result.rawResponse` — present for non-3DS or when Paymob includes it
  /// 2. `cachedCardToken` — from the initial `payWithCard` response (before 3DS)
  /// 3. Fallback — save card visuals (last4/brand) from `cachedSourceData` or
  ///    form fields so the card appears in the UI. The token is marked with a
  ///    `pending:txnId` prefix so the backend can upgrade it later via webhook.
  ///
  /// > **Note:** Paymob delivers the real reusable card token via a
  /// > **server-side webhook** (`Transaction Processed Callback`), which
  /// > requires a backend endpoint.  Until that is set up, saved cards
  /// > with `pending:` tokens cannot be used for one-tap repayment.
  static Future<void> maybeSaveCard({
    required PaymobPaymentResult result,
    required String holderName,
    required String expiryMonth,
    required String expiryYear,
    String? cachedCardToken,
    Map<String, dynamic>? cachedSourceData,
    SavedCardsService? service,
  }) async {
    // 1. Try extracting from the result (non-3DS / if Paymob includes it)
    SavedCard? card = extractSavedCard(result);

    // 2. Try the cached token from the initial payWithCard response
    if (card == null && cachedCardToken != null) {
      developer.log(
        'maybeSaveCard → using cached token: ${cachedCardToken.substring(0, 8)}…',
        name: 'PaymobCubit',
      );

      final pan = cachedSourceData?['pan']?.toString() ?? '';
      final last4 = pan.length >= 4 ? pan.substring(pan.length - 4) : pan;
      final brand = cachedSourceData?['sub_type']?.toString() ??
          cachedSourceData?['type']?.toString() ??
          'Card';

      card = SavedCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        token: cachedCardToken,
        last4: last4,
        brand: brand,
        holderName: '',
        expiryMonth: '',
        expiryYear: '',
        savedAt: DateTime.now(),
      );
    }

    // 3. Fallback: no token at all — save card visuals with a pending token.
    //    The card will show in the UI but can't be used for repayment until
    //    a backend webhook provides the real token.
    if (card == null) {
      // Get card info from response source_data (nested or cached flat)
      final raw = result.rawResponse;
      final nestedSource = raw?['source_data'];
      final sourceMap = nestedSource is Map<String, dynamic>
          ? nestedSource
          : cachedSourceData;

      final pan = sourceMap?['pan']?.toString() ?? '';
      final last4 = pan.length >= 4 ? pan.substring(pan.length - 4) : pan;
      final brand = sourceMap?['sub_type']?.toString() ??
          sourceMap?['type']?.toString() ??
          'Card';
      final txnId = result.transactionId ?? 'unknown';

      if (last4.isNotEmpty) {
        developer.log(
          'maybeSaveCard → no token from API (requires backend webhook). '
          'Saving card visuals: last4=$last4 brand=$brand txn=$txnId',
          name: 'PaymobCubit',
        );

        card = SavedCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          token: 'pending:$txnId', // placeholder — backend will replace
          last4: last4,
          brand: brand,
          holderName: '',
          expiryMonth: '',
          expiryYear: '',
          savedAt: DateTime.now(),
        );
      } else {
        developer.log(
          'maybeSaveCard → no token and no card info available, skipping save',
          name: 'PaymobCubit',
        );
        return;
      }
    }

    final enriched = SavedCard(
      id: card.id,
      token: card.token,
      last4: card.last4.isNotEmpty ? card.last4 : _last4FromHolder(holderName),
      brand: card.brand,
      holderName: holderName,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      savedAt: card.savedAt,
    );

    final svc = service ?? SavedCardsService();
    await svc.saveCard(enriched);
    developer.log(
      'maybeSaveCard → card saved! last4=${enriched.last4} '
      'brand=${enriched.brand} tokenPrefix=${enriched.token.substring(0, enriched.token.length.clamp(0, 10))}',
      name: 'PaymobCubit',
    );
  }

  /// Helper: we don't really have last4 from the holder name,
  /// return empty string as a safe fallback.
  static String _last4FromHolder(String _) => '';

  // ─────────────────────────────────────────────────────────────────────────
  // Pay with wallet
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> submitWalletPayment(String mobileNumber) async {
    if (_keyData == null) {
      emit(const PaymentFailed(message: 'Payment not prepared yet'));
      return;
    }

    try {
      emit(const PaymentProcessing());

      final result = await _apiService.payWithWallet(
        paymentToken: _keyData!.paymentToken,
        mobileNumber: mobileNumber,
      );

      if (result.isSuccess) {
        emit(PaymentSuccess(result: result));
      } else if (result.needsRedirect) {
        final txnId = result.rawResponse?['id'] as int?;
        emit(PaymentRedirect(
          redirectUrl: result.redirectUrl!,
          transactionId: txnId,
        ));
      } else {
        emit(PaymentFailed(message: result.message ?? 'Wallet payment failed'));
      }
    } catch (e) {
      emit(PaymentFailed(message: _friendlyError(e)));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Transaction polling (for redirect flows)
  // ─────────────────────────────────────────────────────────────────────────

  /// Starts polling Paymob's transaction status API every [intervalSeconds].
  ///
  /// The poll stops automatically when success or failure is confirmed,
  /// or after [maxAttempts] tries.
  void startPollingTransaction({
    required int transactionId,
    int intervalSeconds = 4,
    int maxAttempts = 30,
  }) {
    _pendingTransactionId = transactionId;
    int attempts = 0;

    developer.log(
      'Paymob polling started for txn $transactionId',
      name: 'PaymobCubit',
    );

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) async {
        attempts++;
        if (attempts > maxAttempts) {
          timer.cancel();
          developer.log(
            'Paymob polling timeout for txn $transactionId',
            name: 'PaymobCubit',
          );
          emit(const PaymentFailed(
            message: 'Payment confirmation timed out — please check your order status',
          ));
          return;
        }

        try {
          final data = await _apiService.checkTransactionStatus(transactionId);
          final success = data['success'] == true;
          final pending = data['pending'] == true;

          developer.log(
            'Paymob poll #$attempts txn $transactionId → '
            'success=$success pending=$pending '
            'token=${data['token'] != null} '
            'source_data.token=${(data['source_data'] as Map?)?['token']}',
            name: 'PaymobCubit',
          );

          if (success) {
            timer.cancel();
            emit(PaymentSuccess(
              result: PaymobPaymentResult.success(
                transactionId: '$transactionId',
                orderId: '${data['order']?['id'] ?? ''}',
                amountCents: data['amount_cents'] as int?,
                rawResponse: data,
              ),
            ));
          } else if (!pending) {
            // Not pending and not success means failed/declined
            timer.cancel();
            final msg = data['data']?['message']?.toString() ??
                data['txn_response_code']?.toString() ??
                'Payment was declined';
            emit(PaymentFailed(message: msg));
          }
          // If still pending, keep polling
        } catch (e) {
          developer.log(
            'Paymob poll error: $e',
            name: 'PaymobCubit',
          );
          // Don't stop polling on network errors — just skip this attempt
        }
      },
    );
  }

  /// Stops any active transaction polling.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Signals the UI that we're waiting for polling to confirm the payment.
  ///
  /// Called after the WebView closes with a success URL callback but before
  /// polling has returned the full transaction data.
  void showConfirming() {
    emit(const PaymentPreparing(message: 'Confirming payment...'));
  }

  /// Performs a **single-shot** transaction check and emits the result.
  ///
  /// Call this after the WebView returns `success=true` via URL callback to
  /// get the full transaction data (including the card reuse token).
  /// Retries up to 5 times with a 2-second delay between each attempt,
  /// because Paymob may take a moment to finalise the transaction.
  Future<void> confirmTransaction({required int transactionId}) async {
    stopPolling(); // no need for the background timer anymore

    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        final data =
            await _apiService.checkTransactionStatus(transactionId);
        final success = data['success'] == true;
        final pending = data['pending'] == true;

        developer.log(
          'Paymob confirm #$attempt txn $transactionId → '
          'success=$success pending=$pending '
          'token=${data['token'] != null} '
          'source_data.token=${(data['source_data'] as Map?)?['token']}',
          name: 'PaymobCubit',
        );

        if (success) {
          emit(PaymentSuccess(
            result: PaymobPaymentResult.success(
              transactionId: '$transactionId',
              orderId: '${data['order']?['id'] ?? ''}',
              amountCents: data['amount_cents'] as int?,
              rawResponse: data,
            ),
          ));
          return;
        } else if (!pending) {
          // Failed/declined
          final msg = data['data']?['message']?.toString() ??
              data['txn_response_code']?.toString() ??
              'Payment was declined';
          emit(PaymentFailed(message: msg));
          return;
        }
      } catch (e) {
        developer.log(
          'Paymob confirm error #$attempt: $e',
          name: 'PaymobCubit',
        );
      }

      // Wait before retrying (transaction may still be finalising)
      if (attempt < 5) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // All attempts exhausted but still pending — emit success from URL
    // (payment DID succeed on Paymob's side, we just can't get full data)
    developer.log(
      'Paymob confirm exhausted — falling back to URL-based success',
      name: 'PaymobCubit',
    );
    emit(PaymentSuccess(
      result: PaymobPaymentResult.success(
        transactionId: '$transactionId',
      ),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle callback after 3D-Secure / wallet redirect
  // ─────────────────────────────────────────────────────────────────────────

  /// Call this when your WebView catches the Paymob callback URL.
  void handleRedirectResult(Uri callbackUri) {
    final params = callbackUri.queryParameters;
    final success = params['success'] == 'true';
    final txnId = params['id'] ?? params['transaction_id'] ?? '';

    if (success) {
      emit(PaymentSuccess(
        result: PaymobPaymentResult.success(transactionId: txnId),
      ));
    } else {
      emit(PaymentFailed(
        message: params['data.message'] ?? 'Payment was declined',
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reset to initial
  // ─────────────────────────────────────────────────────────────────────────

  void reset() {
    _pollTimer?.cancel();
    _keyData = null;
    _pendingTransactionId = null;
    _pendingCardToken = null;
    _pendingSourceData = null;
    _saveCardRequested = false;
    emit(const PaymentInitial());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Iframe URL (fallback)
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the iframe checkout URL — useful if you want to fall back to
  /// Paymob's hosted payment page.
  String? get iframeUrl {
    if (_keyData == null) return null;
    return _apiService.getIframeUrl(_keyData!.paymentToken);
  }

  // ─────────────────────────────────────────────────────────────────────────
  String _friendlyError(Object e) {
    if (e is String) return e;

    // DioException — extract the useful part
    if (e.toString().contains('DioException')) {
      if (e.toString().contains('401')) {
        return 'Authentication failed — please check your Paymob API key';
      }
      if (e.toString().contains('403')) {
        return 'Access denied — integration ID may be incorrect';
      }
      if (e.toString().contains('404')) {
        return 'Service not found — please check the API configuration';
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        return 'No internet connection — please try again';
      }
      if (e.toString().contains('timeout')) {
        return 'Connection timed out — please try again';
      }
      return 'Something went wrong — please try again';
    }

    return e.toString().replaceFirst('Exception: ', '');
  }
}
