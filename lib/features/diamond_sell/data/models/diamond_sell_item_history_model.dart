class DiamondSellItemHistoryModel {
  final int id;
  final double price;
  final double dollars;
  final String diamondName;
  final double diamondWeight;
  final String kindName;
  final String vendorName;

  DiamondSellItemHistoryModel({
    required this.id,
    required this.price,
    required this.dollars,
    required this.diamondName,
    required this.diamondWeight,
    required this.kindName,
    required this.vendorName,
  });

  factory DiamondSellItemHistoryModel.fromJson(Map<String, dynamic> json) {
    final diamond = json['diamond'] as Map<String, dynamic>? ?? {};
    final kind = json['kind'] as Map<String, dynamic>? ?? {};
    final vendor = json['vendor'] as Map<String, dynamic>? ?? {};
    return DiamondSellItemHistoryModel(
      id: _parseInt(json['id']),
      price: _parseDouble(json['price']),
      dollars: _parseDouble(json['dollars']),
      diamondName: diamond['name']?.toString() ?? '',
      diamondWeight: _parseDouble(diamond['weight']),
      kindName: kind['name']?.toString() ?? '',
      vendorName: vendor['name']?.toString() ?? '',
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
