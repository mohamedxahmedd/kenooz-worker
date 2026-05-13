import 'package:json_annotation/json_annotation.dart';

part 'carat_model.g.dart';

@JsonSerializable()
class CaratModel {
  final int id;
  final String carat;
  final double fixed;
  final double price;

  CaratModel({
    required this.id,
    required this.carat,
    required this.fixed,
    required this.price,
  });

  factory CaratModel.fromJson(Map<String, dynamic> json) {
    return CaratModel(
      id: _parseInt(json['id']),
      carat: json['carat']?.toString() ?? '',
      fixed: _parseDouble(json['fixed']),
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
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid double value: $value');
  }

  Map<String, dynamic> toJson() => _$CaratModelToJson(this);
}
