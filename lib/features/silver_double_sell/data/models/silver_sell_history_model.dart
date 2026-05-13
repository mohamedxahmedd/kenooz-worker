import 'package:kenooz_worker_app/features/gold_double_sell/data/models/sell_history_refs.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_buy_history_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_sell_item_history_model.dart';

class SilverSellHistoryModel {
  final int id;
  final double total;
  final String sellDate;
  final String? notes;
  final HistorySellClientRef client;
  final HistorySellWorkerRef worker;
  final List<SilverSellItemHistoryModel> silverSellItems;
  final List<SilverBuyHistoryModel> silverBuys;

  SilverSellHistoryModel({
    required this.id,
    required this.total,
    required this.sellDate,
    this.notes,
    required this.client,
    required this.worker,
    required this.silverSellItems,
    required this.silverBuys,
  });

  bool get hasBuy => silverBuys.isNotEmpty;
  int get itemCount => silverSellItems.length;

  factory SilverSellHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawSellItems = json['silver_sell_items'] as List<dynamic>? ?? [];
    final rawBuys = json['silver_buys'] as List<dynamic>? ?? [];
    return SilverSellHistoryModel(
      id: _parseInt(json['id']),
      total: _parseDouble(json['total']),
      sellDate: json['sell_date']?.toString() ?? '',
      notes: json['notes']?.toString(),
      client: HistorySellClientRef.fromJson(
          json['client'] as Map<String, dynamic>? ?? {}),
      worker: HistorySellWorkerRef.fromJson(
          json['worker'] as Map<String, dynamic>? ?? {}),
      silverSellItems: rawSellItems
          .map((e) =>
              SilverSellItemHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      silverBuys: rawBuys
          .map((e) => SilverBuyHistoryModel.fromJson(e as Map<String, dynamic>))
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
