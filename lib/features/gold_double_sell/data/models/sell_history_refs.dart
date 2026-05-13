/// Lightweight client & worker reference objects used inside history responses.
/// These only contain the fields returned by the history endpoints — unlike the
/// full ClientModel which has email, gender, points, etc.
class HistorySellClientRef {
  final int id;
  final String name;
  final String phone;

  HistorySellClientRef({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory HistorySellClientRef.fromJson(Map<String, dynamic> json) {
    return HistorySellClientRef(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class HistorySellWorkerRef {
  final int id;
  final String name;

  HistorySellWorkerRef({required this.id, required this.name});

  factory HistorySellWorkerRef.fromJson(Map<String, dynamic> json) {
    return HistorySellWorkerRef(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
