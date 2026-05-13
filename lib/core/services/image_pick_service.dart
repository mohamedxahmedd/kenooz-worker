import 'package:file_picker/file_picker.dart';

/// Lightweight, framework-neutral picked-image record.
class PickedImage {
  const PickedImage({required this.path, required this.name});
  final String path;
  final String name;
}

enum ImagePickSource { camera, gallery }

/// Desktop image picking via the native file dialog ([FilePicker]).
/// `ImagePickSource` is accepted for API parity but desktops have no camera,
/// so both values resolve to the file picker.
class ImagePickService {
  ImagePickService._();
  static final ImagePickService instance = ImagePickService._();

  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  Future<PickedImage?> pickSingle({
    ImagePickSource source = ImagePickSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
    );
    final file = result?.files.firstOrNull;
    if (file == null || file.path == null) return null;
    return PickedImage(path: file.path!, name: file.name);
  }

  Future<List<PickedImage>> pickMulti({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: true,
    );
    if (result == null) return const [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => PickedImage(path: f.path!, name: f.name))
        .toList();
  }

  /// Always `false` on desktop.
  bool get supportsCamera => false;
}
