import 'package:json_annotation/json_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';

part 'gold_product_model.g.dart';

@JsonSerializable(createFactory: false)
class GoldProductModel {
  final int id;
  final int shopId;
  final int kindId;
  final int caratId;
  final int vendorId;
  final String name;
  final double grams;
  final double profit;
  final double mc;
  final bool isMcD;
  final bool isSold;
  final double gramPrice;
  final String caratName;
  final String caratLabel;
  final GoldCaratModel? caratModel;
  final List<String> media;

  GoldProductModel({
    required this.id,
    required this.shopId,
    required this.kindId,
    required this.caratId,
    required this.vendorId,
    required this.name,
    required this.grams,
    required this.profit,
    required this.mc,
    required this.isMcD,
    required this.isSold,
    required this.gramPrice,
    required this.caratName,
    required this.caratLabel,
    required this.caratModel,
    required this.media,
  });

  factory GoldProductModel.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List<dynamic>? ?? const [];
    final caratJson = json['carat'];

    return GoldProductModel(
      id: _parseInt(json['id']),
      shopId: _parseIntOrZero(json['shop_id']),
      kindId: _parseIntOrZero(json['kind_id']),
      caratId: _parseIntOrZero(json['carat_id']),
      vendorId: _parseIntOrZero(json['vendor_id']),
      name: json['name']?.toString() ?? '',
      grams: _parseDoubleOrZero(json['grams']),
      profit: _parseDoubleOrZero(json['profit']),
      mc: _parseDoubleOrZero(json['mc']),
      isMcD: _parseIntOrZero(json['is_mc_d']) == 1,
      isSold: _parseIntOrZero(json['is_sold']) == 1,
      gramPrice: _parseDoubleOrZero(
        json['gram_price'] ?? json['price_per_gram'] ?? json['price'],
      ),
      caratName: json['carat_name']?.toString() ?? '',
      caratLabel: json['carat'] is String ? json['carat'].toString() : '',
      caratModel: caratJson is Map<String, dynamic>
          ? GoldCaratModel.fromJson(caratJson)
          : null,
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

  Map<String, dynamic> toJson() => _$GoldProductModelToJson(this);
}
