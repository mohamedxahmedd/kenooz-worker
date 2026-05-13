import 'package:json_annotation/json_annotation.dart';

part 'client_model.g.dart';

@JsonSerializable(createFactory: false)
class ClientModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final int points;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.points,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      points: _parseIntOrZero(json['points']),
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

  static int _parseIntOrZero(dynamic value) {
    if (value == null) return 0;
    try {
      return _parseInt(value);
    } catch (_) {
      return 0;
    }
  }

  Map<String, dynamic> toJson() => _$ClientModelToJson(this);
}
