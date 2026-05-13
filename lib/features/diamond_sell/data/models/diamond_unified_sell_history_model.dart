import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_record_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_sell_record_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/sell_history_refs.dart';

class DiamondUnifiedSellHistoryModel {
  final String unifiedId;
  final String sellDate;
  final String? notes;
  final double grandTotal;
  final HistorySellClientRef client;
  final HistorySellWorkerRef worker;
  final List<DiamondSellRecordHistoryModel> diamondSells;
  final List<StoneSellRecordHistoryModel> stoneSells;

  DiamondUnifiedSellHistoryModel({
    required this.unifiedId,
    required this.sellDate,
    this.notes,
    required this.grandTotal,
    required this.client,
    required this.worker,
    required this.diamondSells,
    required this.stoneSells,
  });

  int get totalDiamondItems =>
      diamondSells.fold(0, (s, d) => s + d.items.length);
  int get totalStoneItems =>
      stoneSells.fold(0, (s, d) => s + d.items.length);
  int get totalItemCount => totalDiamondItems + totalStoneItems;

  factory DiamondUnifiedSellHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawDiamondSells = json['diamond_sells'] as List<dynamic>? ?? [];
    final rawStoneSells = json['stone_sells'] as List<dynamic>? ?? [];
    return DiamondUnifiedSellHistoryModel(
      unifiedId: json['unified_id']?.toString() ?? '',
      sellDate: json['sell_date']?.toString() ?? '',
      notes: json['notes']?.toString(),
      grandTotal: _parseDouble(json['grand_total']),
      client: HistorySellClientRef.fromJson(
          json['client'] as Map<String, dynamic>? ?? {}),
      worker: HistorySellWorkerRef.fromJson(
          json['worker'] as Map<String, dynamic>? ?? {}),
      diamondSells: rawDiamondSells
          .map((e) => DiamondSellRecordHistoryModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      stoneSells: rawStoneSells
          .map((e) => StoneSellRecordHistoryModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}
