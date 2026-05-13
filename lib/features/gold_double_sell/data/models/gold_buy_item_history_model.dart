class GoldBuyItemHistoryModel {
  final int id;
  final double grams;
  final double loss;
  final double gramPrice;
  final double price;
  final String caratLabel;
  final String? boxName;

  GoldBuyItemHistoryModel({
    required this.id,
    required this.grams,
    required this.loss,
    required this.gramPrice,
    required this.price,
    required this.caratLabel,
    this.boxName,
  });

  double get netGrams => grams - loss;

  factory GoldBuyItemHistoryModel.fromJson(Map<String, dynamic> json) {
    final carat = json['carat'] as Map<String, dynamic>? ?? {};
    final box = json['box'] as Map<String, dynamic>?;
    return GoldBuyItemHistoryModel(
      id: _parseInt(json['id']),
      grams: _parseDouble(json['grams']),
      loss: _parseDouble(json['loss']),
      gramPrice: _parseDouble(json['gram_price']),
      price: _parseDouble(json['price']),
      caratLabel: carat['carat']?.toString() ?? '',
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
