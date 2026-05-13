class OrderStatsEntryModel {
  final int count;
  final double total;

  OrderStatsEntryModel({
    required this.count,
    required this.total,
  });

  factory OrderStatsEntryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatsEntryModel(
      count: _parseInt(json['count']),
      total: _parseDouble(json['total']),
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

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid double value: $value');
  }
}
