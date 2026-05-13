class SilverSellFindModel {
  final int id;
  final String sellDate;
  final double total;
  final double totalGrams;

  SilverSellFindModel({
    required this.id,
    required this.sellDate,
    required this.total,
    required this.totalGrams,
  });

  factory SilverSellFindModel.fromJson(Map<String, dynamic> json) {
    return SilverSellFindModel(
      id: _parseInt(json['id']),
      sellDate: json['sell_date']?.toString() ?? '',
      total: _parseDouble(json['total']),
      totalGrams: _parseDouble(json['total_grams']),
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
