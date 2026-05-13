class CreateBlogRequestModel {
  final String title;
  final String? subtitle;
  final String details;
  final bool isActive;
  final List<String> imagePaths;

  CreateBlogRequestModel({
    required this.title,
    this.subtitle,
    required this.details,
    required this.isActive,
    this.imagePaths = const [],
  });
}
