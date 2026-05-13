import 'package:json_annotation/json_annotation.dart';

part 'double_sell_response_model.g.dart';

@JsonSerializable(createFactory: false)
class DoubleSellResponseModel {
  final String status;
  final int sellId;
  final int? buyId;
  final double total;

  DoubleSellResponseModel({
    required this.status,
    required this.sellId,
    required this.buyId,
    required this.total,
  });

  factory DoubleSellResponseModel.fromJson(Map<String, dynamic> json) {
    return DoubleSellResponseModel(
      status: json['status']?.toString() ?? '',
      sellId: _parseInt(json['sell_id']),
      buyId: json['buy_id'] != null ? _parseInt(json['buy_id']) : null,
      total: _parseDouble(json['total']),
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

  Map<String, dynamic> toJson() => _$DoubleSellResponseModelToJson(this);
}
