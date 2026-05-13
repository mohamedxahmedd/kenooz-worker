import 'order_stats_entry_model.dart';

class OrderStatsModel {
  final Map<String, OrderStatsEntryModel> entries;
  final int totalCount;
  final double totalAmount;

  OrderStatsModel({
    required this.entries,
    required this.totalCount,
    required this.totalAmount,
  });

  factory OrderStatsModel.empty() {
    return OrderStatsModel(
      entries: {},
      totalCount: 0,
      totalAmount: 0.0,
    );
  }

  factory OrderStatsModel.fromJson(Map<String, dynamic> json, String period) {
    final entries = <String, OrderStatsEntryModel>{};

    // Extract all entries except the summary keys
    json.forEach((key, value) {
      if (!key.startsWith(period)) {
        if (value is Map<String, dynamic>) {
          entries[key] = OrderStatsEntryModel.fromJson(value);
        }
      }
    });

    // Get summary keys based on period
    final countKey = '${period}_count';
    final totalKey = '${period}_total';

    final totalCount = json[countKey] != null ? _parseInt(json[countKey]) : 0;
    final totalAmount = json[totalKey] != null ? _parseDouble(json[totalKey]) : 0.0;

    return OrderStatsModel(
      entries: entries,
      totalCount: totalCount,
      totalAmount: totalAmount,
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
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }
}
