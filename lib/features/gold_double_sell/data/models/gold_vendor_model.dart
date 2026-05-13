import 'package:json_annotation/json_annotation.dart';

part 'gold_vendor_model.g.dart';

@JsonSerializable(createFactory: false)
class GoldVendorModel {
  final int id;
  final String name;
  final int caratId;
  final int currencyId;
  final double gold;
  final double cash;

  GoldVendorModel({
    required this.id,
    required this.name,
    required this.caratId,
    required this.currencyId,
    required this.gold,
    required this.cash,
  });

  factory GoldVendorModel.fromJson(Map<String, dynamic> json) {
    return GoldVendorModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      caratId: _parseInt(json['carat_id']),
      currencyId: _parseInt(json['currency_id']),
      gold: _parseDouble(json['gold']),
      cash: _parseDouble(json['cash']),
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

  Map<String, dynamic> toJson() => _$GoldVendorModelToJson(this);
}
