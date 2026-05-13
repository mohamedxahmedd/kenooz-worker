class HangResponseModel {
  final String status;
  final String message;
  final int count;

  HangResponseModel({
    required this.status,
    required this.message,
    required this.count,
  });

  factory HangResponseModel.fromJson(Map<String, dynamic> json) {
    return HangResponseModel(
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? '',
      count: _parseInt(json['count']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
