class StoneSellItemHistoryModel {
  final int id;
  final double price;
  final double dollars;
  final double weight;
  final String stoneName;
  final String companyName;

  StoneSellItemHistoryModel({
    required this.id,
    required this.price,
    required this.dollars,
    required this.weight,
    required this.stoneName,
    required this.companyName,
  });

  factory StoneSellItemHistoryModel.fromJson(Map<String, dynamic> json) {
    final stone = json['stone'] as Map<String, dynamic>? ?? {};
    final company = json['company'] as Map<String, dynamic>? ?? {};
    return StoneSellItemHistoryModel(
      id: _parseInt(json['id']),
      price: _parseDouble(json['price']),
      dollars: _parseDouble(json['dollars']),
      weight: _parseDouble(json['weight']),
      stoneName: stone['name']?.toString() ?? '',
      companyName: company['name']?.toString() ?? '',
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
