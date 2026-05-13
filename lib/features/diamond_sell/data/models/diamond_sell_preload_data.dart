import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/usd_rate_model.dart';

class DiamondSellPreloadData {
  final UsdRateModel usdRate;
  final List<PaymentAccountModel> accounts;

  DiamondSellPreloadData({
    required this.usdRate,
    required this.accounts,
  });
}
