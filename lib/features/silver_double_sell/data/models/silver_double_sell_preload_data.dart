import 'package:kenooz_worker_app/features/gold_double_sell/data/models/payment_account_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_box_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_kind_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_vendor_model.dart';

class SilverDoubleSellPreloadData {
  final List<SilverCaratModel> carats;
  final List<SilverKindModel> kinds;
  final List<SilverBoxModel> boxes;
  final List<SilverVendorModel> vendors;
  final List<ShopWorkerModel> workers;
  final List<PaymentAccountModel> accounts;

  SilverDoubleSellPreloadData({
    required this.carats,
    required this.kinds,
    required this.boxes,
    required this.vendors,
    required this.workers,
    required this.accounts,
  });
}
