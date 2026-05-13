import 'package:json_annotation/json_annotation.dart';

part 'account_currency_model.g.dart';

@JsonSerializable(createFactory: false)
class AccountCurrencyModel {
  final int id;
  final String code;
  final double price;

  AccountCurrencyModel({
    required this.id,
    required this.code,
    required this.price,
  });

  factory AccountCurrencyModel.fromJson(Map<String, dynamic> json) {
    return AccountCurrencyModel(
      id: _parseInt(json['id']),
      code: json['code']?.toString() ?? '',
      price: _parseDouble(json['price']),
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

  Map<String, dynamic> toJson() => _$AccountCurrencyModelToJson(this);
}
