import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_buy_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/sell_history_refs.dart';

class GoldSellHistoryModel {
  final int id;
  final double total;
  final String sellDate;
  final String? notes;
  final HistorySellClientRef client;
  final HistorySellWorkerRef worker;
  final List<GoldSellItemHistoryModel> goldSellItems;
  final List<GoldBuyHistoryModel> goldBuys;

  GoldSellHistoryModel({
    required this.id,
    required this.total,
    required this.sellDate,
    this.notes,
    required this.client,
    required this.worker,
    required this.goldSellItems,
    required this.goldBuys,
  });

  bool get hasBuy => goldBuys.isNotEmpty;
  int get itemCount => goldSellItems.length;

  factory GoldSellHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawSellItems = json['gold_sell_items'] as List<dynamic>? ?? [];
    final rawBuys = json['gold_buys'] as List<dynamic>? ?? [];
    return GoldSellHistoryModel(
      id: _parseInt(json['id']),
      total: _parseDouble(json['total']),
      sellDate: json['sell_date']?.toString() ?? '',
      notes: json['notes']?.toString(),
      client: HistorySellClientRef.fromJson(
          json['client'] as Map<String, dynamic>? ?? {}),
      worker: HistorySellWorkerRef.fromJson(
          json['worker'] as Map<String, dynamic>? ?? {}),
      goldSellItems: rawSellItems
          .map((e) =>
              GoldSellItemHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      goldBuys: rawBuys
          .map((e) => GoldBuyHistoryModel.fromJson(e as Map<String, dynamic>))
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
