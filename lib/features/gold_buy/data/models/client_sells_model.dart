import 'package:kenooz_worker_app/features/gold_buy/data/models/sell_find_model.dart';

class ClientSellsModel {
  final int id;
  final String name;
  final String phone;
  final List<SellFindModel> goldSells;

  ClientSellsModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.goldSells,
  });

  factory ClientSellsModel.fromJson(Map<String, dynamic> json) {
    final rawSells = json['gold_sells'] as List<dynamic>? ?? [];
    return ClientSellsModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      goldSells: rawSells
          .map((e) => SellFindModel.fromJson(e as Map<String, dynamic>))
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
