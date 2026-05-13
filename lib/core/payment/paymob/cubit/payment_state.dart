import 'package:equatable/equatable.dart';
import '../models/payment_result.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Payment States
/// ──────────────────────────────────────────────────────────────────────────────
abstract class PaymobPaymentState extends Equatable {
  const PaymobPaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state.
class PaymentInitial extends PaymobPaymentState {
  const PaymentInitial();
}

/// The 3-step preparation is running (auth → order → key).
class PaymentPreparing extends PaymobPaymentState {
  final String message;

  const PaymentPreparing({this.message = 'Preparing payment...'});

  @override
  List<Object?> get props => [message];
}

/// Payment key obtained — ready for the user to submit card/wallet details.
class PaymentReady extends PaymobPaymentState {
  final String paymentToken;
  final int orderId;

  const PaymentReady({
    required this.paymentToken,
    required this.orderId,
  });

  @override
  List<Object?> get props => [paymentToken, orderId];
}

/// The pay request is in-flight.
class PaymentProcessing extends PaymobPaymentState {
  const PaymentProcessing();
}

/// Payment completed successfully.
class PaymentSuccess extends PaymobPaymentState {
  final PaymobPaymentResult result;

  const PaymentSuccess({required this.result});

  @override
  List<Object?> get props => [result.transactionId];
}

/// A redirect is needed (3D-Secure / wallet approval).
class PaymentRedirect extends PaymobPaymentState {
  final String redirectUrl;

  /// The Paymob transaction ID — used to poll status after redirect.
  final int? transactionId;

  const PaymentRedirect({
    required this.redirectUrl,
    this.transactionId,
  });

  @override
  List<Object?> get props => [redirectUrl, transactionId];
}

/// Payment failed.
class PaymentFailed extends PaymobPaymentState {
  final String message;

  const PaymentFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
