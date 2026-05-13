class HistoryBuyClientRef {
  final int id;
  final String name;
  final String phone;

  HistoryBuyClientRef({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory HistoryBuyClientRef.fromJson(Map<String, dynamic> json) {
    return HistoryBuyClientRef(
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

class HistoryBuyWorkerRef {
  final int id;
  final String name;

  HistoryBuyWorkerRef({required this.id, required this.name});

  factory HistoryBuyWorkerRef.fromJson(Map<String, dynamic> json) {
    return HistoryBuyWorkerRef(
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

class HistoryBuyVendorRef {
  final int id;
  final String name;

  HistoryBuyVendorRef({required this.id, required this.name});

  factory HistoryBuyVendorRef.fromJson(Map<String, dynamic> json) {
    return HistoryBuyVendorRef(
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
