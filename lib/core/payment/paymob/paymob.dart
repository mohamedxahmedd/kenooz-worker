/// ──────────────────────────────────────────────────────────────────────────────
/// Paymob Package — barrel export
/// ──────────────────────────────────────────────────────────────────────────────
/// Import this single file to get the entire Paymob integration:
///
/// ```dart
/// import 'package:soul/core/payment/paymob/paymob.dart';
/// ```
library paymob;

// Config
export 'paymob_config.dart';

// Models
export 'models/billing_data.dart';
export 'models/card_data.dart';
export 'models/payment_result.dart';
export 'models/saved_card.dart';

// Services
export 'services/paymob_api_service.dart';
export 'services/saved_cards_service.dart';

// Cubit
export 'cubit/payment_cubit.dart';
export 'cubit/payment_state.dart';

// Utils
export 'utils/card_validator.dart';
