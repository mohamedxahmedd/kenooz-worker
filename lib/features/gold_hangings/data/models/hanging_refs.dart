class HangingKindRef {
  final int id;
  final String name;

  HangingKindRef({required this.id, required this.name});

  factory HangingKindRef.fromJson(Map<String, dynamic> json) {
    return HangingKindRef(
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

class HangingCaratRef {
  final int id;
  final String carat;
  final double fixed;
  final double price;

  HangingCaratRef({
    required this.id,
    required this.carat,
    required this.fixed,
    required this.price,
  });

  factory HangingCaratRef.fromJson(Map<String, dynamic> json) {
    return HangingCaratRef(
      id: _parseInt(json['id']),
      carat: json['carat']?.toString() ?? '',
      fixed: _parseDouble(json['fixed']),
      price: _parseDouble(json['price']),
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

class HangingVendorRef {
  final int id;
  final String name;

  HangingVendorRef({required this.id, required this.name});

  factory HangingVendorRef.fromJson(Map<String, dynamic> json) {
    return HangingVendorRef(
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

class HangingWorkerRef {
  final int id;
  final String name;

  HangingWorkerRef({required this.id, required this.name});

  factory HangingWorkerRef.fromJson(Map<String, dynamic> json) {
    return HangingWorkerRef(
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
