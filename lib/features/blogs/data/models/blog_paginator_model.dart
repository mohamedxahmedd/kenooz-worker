import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';

class BlogPaginatorModel {
  final List<BlogModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;

  BlogPaginatorModel({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
  });

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  factory BlogPaginatorModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return BlogPaginatorModel(
      data: rawData
          .map((e) => BlogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      total: _parseInt(json['total']),
      nextPageUrl: json['next_page_url']?.toString(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
