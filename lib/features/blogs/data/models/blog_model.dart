import 'package:kenooz_worker_app/features/blogs/data/models/blog_image_model.dart';

class BlogModel {
  final int id;
  final String title;
  final String? subtitle;
  final String details;
  final bool isActive;
  final List<BlogImageModel> images;
  final String createdAt;
  final String updatedAt;

  BlogModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.details,
    required this.isActive,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get coverImageUrl => images.isNotEmpty ? images.first.url : null;

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    return BlogModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      details: json['details']?.toString() ?? '',
      isActive: _parseInt(json['is_active']) == 1,
      images: rawImages
          .map((e) => BlogImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
