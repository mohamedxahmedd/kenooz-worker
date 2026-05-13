import 'package:kenooz_worker_app/features/home/data/models/gold_rates_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/silver_rates_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/usd_rate_model.dart';

class HomeDataModel {
  final UsdRateModel usdRate;
  final GoldRatesModel goldRates;
  final SilverRatesModel silverRates;

  HomeDataModel({
    required this.usdRate,
    required this.goldRates,
    required this.silverRates,
  });
}
