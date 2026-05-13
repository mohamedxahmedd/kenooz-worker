enum SilverSellItemType { inside, box, outside }

class SilverSellItemHistoryModel {
  final int id;
  final int? silverId;
  final int? boxId;
  final double grams;
  final double? loss;
  final double mc;
  final double profit;
  final double gramPrice;
  final double price;
  final String? silverName;
  final String caratLabel;
  final String kindName;
  final String vendorName;
  final String? boxName;

  SilverSellItemHistoryModel({
    required this.id,
    this.silverId,
    this.boxId,
    required this.grams,
    this.loss,
    required this.mc,
    required this.profit,
    required this.gramPrice,
    required this.price,
    this.silverName,
    required this.caratLabel,
    required this.kindName,
    required this.vendorName,
    this.boxName,
  });

  SilverSellItemType get itemType {
    if (silverId != null) return SilverSellItemType.inside;
    if (boxId != null) return SilverSellItemType.box;
    return SilverSellItemType.outside;
  }

  factory SilverSellItemHistoryModel.fromJson(Map<String, dynamic> json) {
    final silver = json['silver'] as Map<String, dynamic>?;
    final carat = json['carat'] as Map<String, dynamic>? ?? {};
    final kind = json['kind'] as Map<String, dynamic>? ?? {};
    final vendor = json['vendor'] as Map<String, dynamic>? ?? {};
    final box = json['box'] as Map<String, dynamic>?;
    return SilverSellItemHistoryModel(
      id: _parseInt(json['id']),
      silverId: json['silver_id'] != null ? _parseInt(json['silver_id']) : null,
      boxId: json['box_id'] != null ? _parseInt(json['box_id']) : null,
      grams: _parseDouble(json['grams']),
      loss: json['loss'] != null ? _parseDouble(json['loss']) : null,
      mc: _parseDouble(json['mc']),
      profit: _parseDouble(json['profit']),
      gramPrice: _parseDouble(json['gram_price']),
      price: _parseDouble(json['price']),
      silverName: silver?['name']?.toString(),
      caratLabel: carat['carat']?.toString() ?? '',
      kindName: kind['name']?.toString() ?? '',
      vendorName: vendor['name']?.toString() ?? '',
      boxName: box?['name']?.toString(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}
