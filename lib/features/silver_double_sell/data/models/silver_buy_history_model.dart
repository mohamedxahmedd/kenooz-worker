import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_buy_item_history_model.dart';

class SilverBuyHistoryModel {
  final int id;
  final double total;
  final List<SilverBuyItemHistoryModel> items;

  SilverBuyHistoryModel({
    required this.id,
    required this.total,
    required this.items,
  });

  factory SilverBuyHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['silver_buy_items'] as List<dynamic>? ?? [];
    return SilverBuyHistoryModel(
      id: _parseInt(json['id']),
      total: _parseDouble(json['total']),
      items: rawItems
          .map((e) =>
              SilverBuyItemHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}
