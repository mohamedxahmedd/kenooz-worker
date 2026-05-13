import 'package:json_annotation/json_annotation.dart';

part 'diamond_sell_result_model.g.dart';

@JsonSerializable(createFactory: false)
class DiamondSellResultModel {
  final String status;
  final String unifiedId;
  final int? diamondSellId;
  final int? stoneSellId;
  final double grandTotal;

  DiamondSellResultModel({
    required this.status,
    required this.unifiedId,
    this.diamondSellId,
    this.stoneSellId,
    required this.grandTotal,
  });

  factory DiamondSellResultModel.fromJson(Map<String, dynamic> json) {
    return DiamondSellResultModel(
      status: json['status']?.toString() ?? '',
      unifiedId: json['unified_id']?.toString() ?? '',
      diamondSellId: json['diamond_sell_id'] != null
          ? _parseInt(json['diamond_sell_id'])
          : null,
      stoneSellId: json['stone_sell_id'] != null
          ? _parseInt(json['stone_sell_id'])
          : null,
      grandTotal: _parseDouble(json['grand_total']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    throw FormatException('Invalid int value: $value');
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() => _$DiamondSellResultModelToJson(this);
}
