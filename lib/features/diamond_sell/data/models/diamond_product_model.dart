import 'package:json_annotation/json_annotation.dart';

part 'diamond_product_model.g.dart';

@JsonSerializable(createFactory: false)
class DiamondProductModel {
  final int id;
  final int shopId;
  final String name;
  final String type;
  final double totalGWeight;
  final double totalDWeight;
  final double totalWeight;
  final double goldDollars;
  final double dollars;
  final double percentage;
  final double total;
  final bool isSold;
  final List<String> media;

  DiamondProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.type,
    required this.totalGWeight,
    required this.totalDWeight,
    required this.totalWeight,
    required this.goldDollars,
    required this.dollars,
    required this.percentage,
    required this.total,
    required this.isSold,
    required this.media,
  });

  factory DiamondProductModel.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List<dynamic>? ?? const [];

    return DiamondProductModel(
      id: _parseInt(json['id']),
      shopId: _parseIntOrZero(json['shop_id']),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'diamond',
      totalGWeight: _parseDoubleOrZero(json['total_g_weight']),
      totalDWeight: _parseDoubleOrZero(json['total_d_weight']),
      totalWeight: _parseDoubleOrZero(json['total_weight']),
      goldDollars: _parseDoubleOrZero(json['gold_dollars']),
      dollars: _parseDoubleOrZero(json['dollars']),
      percentage: _parseDoubleOrZero(json['percentage']),
      total: _parseDoubleOrZero(json['total']),
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

  Map<String, dynamic> toJson() => _$DiamondProductModelToJson(this);
}
