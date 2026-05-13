import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanging_refs.dart';

class AvailableGoldModel {
  final int id;
  final String name;
  final double grams;
  final HangingKindRef kind;
  final HangingCaratRef carat;
  final String? image;

  AvailableGoldModel({
    required this.id,
    required this.name,
    required this.grams,
    required this.kind,
    required this.carat,
    this.image,
  });

  factory AvailableGoldModel.fromJson(Map<String, dynamic> json) {
    final kindJson = json['kind'] as Map<String, dynamic>? ?? {};
    final caratJson = json['carat'] as Map<String, dynamic>? ?? {};

    return AvailableGoldModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      grams: _parseDouble(json['grams']),
      kind: HangingKindRef.fromJson(kindJson),
      carat: HangingCaratRef.fromJson(caratJson),
      image: json['image']?.toString(),
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
