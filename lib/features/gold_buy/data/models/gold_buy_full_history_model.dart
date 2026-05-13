import 'package:kenooz_worker_app/features/gold_buy/data/models/buy_history_refs.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_buy_item_history_model.dart';

class GoldBuyFullHistoryModel {
  final int id;
  final double total;
  final String? notes;
  final int? sellId;
  final bool isChanged;
  final String createdAt;
  final HistoryBuyClientRef? client;
  final HistoryBuyWorkerRef worker;
  final HistoryBuyVendorRef? vendor;
  final List<GoldBuyItemHistoryModel> items;

  GoldBuyFullHistoryModel({
    required this.id,
    required this.total,
    this.notes,
    this.sellId,
    required this.isChanged,
    required this.createdAt,
    this.client,
    required this.worker,
    this.vendor,
    required this.items,
  });

  // Computed helpers
  bool get hasClient => client != null;
  bool get hasVendor => vendor != null;
  bool get isLinkedToSell => isChanged && sellId != null;
  int get itemCount => items.length;

  factory GoldBuyFullHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['gold_buy_items'] as List<dynamic>? ?? [];
    final clientJson = json['client'] as Map<String, dynamic>?;
    final vendorJson = json['vendor'] as Map<String, dynamic>?;
    final workerJson = json['worker'] as Map<String, dynamic>? ?? {};

    return GoldBuyFullHistoryModel(
      id: _parseInt(json['id']),
      total: _parseDouble(json['total']),
      notes: json['notes']?.toString(),
      sellId: json['sell_id'] != null ? _parseInt(json['sell_id']) : null,
      isChanged: _parseInt(json['is_changed']) == 1,
      createdAt: json['created_at']?.toString() ?? '',
      client: clientJson != null
          ? HistoryBuyClientRef.fromJson(clientJson)
          : null,
      worker: HistoryBuyWorkerRef.fromJson(workerJson),
      vendor: vendorJson != null
          ? HistoryBuyVendorRef.fromJson(vendorJson)
          : null,
      items: rawItems
          .map(
            (e) => GoldBuyItemHistoryModel.fromJson(e as Map<String, dynamic>),
          )
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
