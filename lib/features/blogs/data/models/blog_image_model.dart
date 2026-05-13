class BlogImageModel {
  final int id;
  final String url;

  BlogImageModel({required this.id, required this.url});

  factory BlogImageModel.fromJson(Map<String, dynamic> json) {
    return BlogImageModel(
      id: _parseInt(json['id']),
      url: json['url']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
