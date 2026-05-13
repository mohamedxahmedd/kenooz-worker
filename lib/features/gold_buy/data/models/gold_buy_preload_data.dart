import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_box_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';

class GoldBuyPreloadData {
  final List<GoldCaratModel> carats;
  final List<GoldBoxModel> boxes;
  final List<GoldVendorModel> vendors;
  final List<ShopWorkerModel> workers;
  final List<PaymentAccountModel> accounts;

  GoldBuyPreloadData({
    required this.carats,
    required this.boxes,
    required this.vendors,
    required this.workers,
    required this.accounts,
  });
}
