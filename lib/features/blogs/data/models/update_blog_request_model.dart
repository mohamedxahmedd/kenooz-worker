class UpdateBlogRequestModel {
  final int id;
  final String? title;
  final String? subtitle;
  final String? details;
  final bool? isActive;

  /// New image files to upload. If empty, the existing images are untouched.
  final List<String> newImagePaths;

  /// `true` (default) replaces all existing images with [newImagePaths].
  /// `false` appends them.
  /// Ignored when [newImagePaths] is empty.
  final bool replaceImages;

  UpdateBlogRequestModel({
    required this.id,
    this.title,
    this.subtitle,
    this.details,
    this.isActive,
    this.newImagePaths = const [],
    this.replaceImages = true,
  });
}
