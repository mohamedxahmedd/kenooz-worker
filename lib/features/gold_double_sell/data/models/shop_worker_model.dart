import 'package:json_annotation/json_annotation.dart';

part 'shop_worker_model.g.dart';

@JsonSerializable(createFactory: false)
class ShopWorkerModel {
  final int id;
  final String name;

  ShopWorkerModel({required this.id, required this.name});

  factory ShopWorkerModel.fromJson(Map<String, dynamic> json) {
    return ShopWorkerModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
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

  Map<String, dynamic> toJson() => _$ShopWorkerModelToJson(this);
}
