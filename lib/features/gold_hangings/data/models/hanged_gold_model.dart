import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanging_refs.dart';

class HangedGoldModel {
  final int id;
  final String name;
  final double grams;
  final double mc;
  final int isMcD;
  final double profit;
  final HangingKindRef kind;
  final HangingCaratRef carat;
  final HangingVendorRef? vendor;
  final String? image;
  final String hangedAt;
  final HangingWorkerRef? hangedBy;
  final String? hangNote;

  HangedGoldModel({
    required this.id,
    required this.name,
    required this.grams,
    required this.mc,
    required this.isMcD,
    required this.profit,
    required this.kind,
    required this.carat,
    this.vendor,
    this.image,
    required this.hangedAt,
    this.hangedBy,
    this.hangNote,
  });

  bool get isMcInUsd => isMcD == 1;

  factory HangedGoldModel.fromJson(Map<String, dynamic> json) {
    final kindJson = json['kind'] as Map<String, dynamic>? ?? {};
    final caratJson = json['carat'] as Map<String, dynamic>? ?? {};
    final vendorJson = json['vendor'] as Map<String, dynamic>?;
    final hangedByJson = json['hanged_by'] as Map<String, dynamic>?;

    return HangedGoldModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      grams: _parseDouble(json['grams']),
      mc: _parseDouble(json['mc']),
      isMcD: _parseInt(json['is_mc_d']),
      profit: _parseDouble(json['profit']),
      kind: HangingKindRef.fromJson(kindJson),
      carat: HangingCaratRef.fromJson(caratJson),
      vendor: vendorJson != null ? HangingVendorRef.fromJson(vendorJson) : null,
      image: json['image']?.toString(),
      hangedAt: json['hanged_at']?.toString() ?? '',
      hangedBy:
          hangedByJson != null ? HangingWorkerRef.fromJson(hangedByJson) : null,
      hangNote: json['hang_note']?.toString(),
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
