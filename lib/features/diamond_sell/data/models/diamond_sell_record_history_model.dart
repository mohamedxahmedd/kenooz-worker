import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_item_history_model.dart';

class DiamondSellRecordHistoryModel {
  final int id;
  final double total;
  final List<DiamondSellItemHistoryModel> items;

  DiamondSellRecordHistoryModel({
    required this.id,
    required this.total,
    required this.items,
  });

  factory DiamondSellRecordHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['diamond_sell_items'] as List<dynamic>? ?? [];
    return DiamondSellRecordHistoryModel(
      id: _parseInt(json['id']),
      total: _parseDouble(json['total']),
      items: rawItems
          .map((e) =>
              DiamondSellItemHistoryModel.fromJson(e as Map<String, dynamic>))
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
