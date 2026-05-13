import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_sell_find_model.dart';

class SilverClientSellsModel {
  final int id;
  final String name;
  final String phone;
  final List<SilverSellFindModel> silverSells;

  SilverClientSellsModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.silverSells,
  });

  factory SilverClientSellsModel.fromJson(Map<String, dynamic> json) {
    final rawSells = json['silver_sells'] as List<dynamic>? ?? [];
    return SilverClientSellsModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      silverSells: rawSells
          .map((e) => SilverSellFindModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
