import 'package:json_annotation/json_annotation.dart';

part 'payment_account_model.g.dart';

@JsonSerializable(createFactory: false)
class PaymentAccountModel {
  final int id;
  final String name;
  final double balance;
  final int currencyId;
  final int methodId;
  final String currencyCode;
  final double currencyPrice;

  PaymentAccountModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.currencyId,
    required this.methodId,
    required this.currencyCode,
    required this.currencyPrice,
  });

  factory PaymentAccountModel.fromJson(Map<String, dynamic> json) {
    final currencyJson = json['currency'] as Map<String, dynamic>?;

    return PaymentAccountModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      balance: _parseDouble(json['balance']),
      currencyId: _parseInt(json['currency_id']),
      methodId: _parseInt(json['method_id']),
      currencyCode: currencyJson?['code']?.toString() ?? '',
      currencyPrice: _parseDouble(currencyJson?['price']),
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

  Map<String, dynamic> toJson() => _$PaymentAccountModelToJson(this);
}
