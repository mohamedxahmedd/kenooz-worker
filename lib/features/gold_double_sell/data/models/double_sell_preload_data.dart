import 'package:kenooz_worker_app/features/gold_double_sell/data/models/currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_box_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/gold_rates_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/usd_rate_model.dart';

class DoubleSellPreloadData {
  final List<GoldCaratModel> carats;
  final List<CurrencyModel> currencies;
  final UsdRateModel usdRate;
  final GoldRatesModel goldRates;
  final List<ShopWorkerModel> workers;
  final List<GoldBoxModel> boxes;
  final List<GoldVendorModel> vendors;
  final List<PaymentAccountModel> accounts;

  DoubleSellPreloadData({
    required this.carats,
    required this.currencies,
    required this.usdRate,
    required this.goldRates,
    required this.workers,
    required this.boxes,
    required this.vendors,
    required this.accounts,
  });
}
