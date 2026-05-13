import 'order_product_media_model.dart';

class OrderProductModel {
  final int id;
  final String name;
  final List<OrderProductMediaModel> media;

  OrderProductModel({
    required this.id,
    required this.name,
    required this.media,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => OrderProductMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'media': media.map((e) => e.toJson()).toList(),
      };
}
