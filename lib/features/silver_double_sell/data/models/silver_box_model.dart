import 'package:json_annotation/json_annotation.dart';

part 'silver_box_model.g.dart';

@JsonSerializable(createFactory: false)
class SilverBoxModel {
  final int id;
  final String name;
  final double total;

  SilverBoxModel({required this.id, required this.name, required this.total});

  factory SilverBoxModel.fromJson(Map<String, dynamic> json) {
    return SilverBoxModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
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

  Map<String, dynamic> toJson() => _$SilverBoxModelToJson(this);
}
