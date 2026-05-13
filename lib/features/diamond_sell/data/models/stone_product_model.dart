import 'package:json_annotation/json_annotation.dart';

part 'stone_product_model.g.dart';

@JsonSerializable(createFactory: false)
class StoneProductModel {
  final int id;
  final int shopId;
  final String name;
  final String type;
  final double weight;
  final String reportNumber;
  final String proportion;
  final String polish;
  final String symmetry;
  final double rap;
  final double discount;
  final double dollars;
  final double price;
  final bool isSold;
  final List<String> media;

  StoneProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.type,
    required this.weight,
    required this.reportNumber,
    required this.proportion,
    required this.polish,
    required this.symmetry,
    required this.rap,
    required this.discount,
    required this.dollars,
    required this.price,
    required this.isSold,
    required this.media,
  });

  factory StoneProductModel.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List<dynamic>? ?? const [];

    return StoneProductModel(
      id: _parseInt(json['id']),
      shopId: _parseIntOrZero(json['shop_id']),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'stone',
      weight: _parseDoubleOrZero(json['weight']),
      reportNumber: json['report_number']?.toString() ?? '',
      proportion: json['proportion']?.toString() ?? '',
      polish: json['polish']?.toString() ?? '',
      symmetry: json['symmetry']?.toString() ?? '',
      rap: _parseDoubleOrZero(json['rap']),
      discount: _parseDoubleOrZero(json['discount']),
      dollars: _parseDoubleOrZero(json['dollars']),
      price: _parseDoubleOrZero(json['price']),
      isSold: _parseIntOrZero(json['is_sold']) == 1,
      media: mediaList
          .map((e) {
            if (e is Map<String, dynamic>) {
              return e['original_url']?.toString() ?? '';
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList(),
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

  static double _parseDoubleOrZero(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() => _$StoneProductModelToJson(this);
}
