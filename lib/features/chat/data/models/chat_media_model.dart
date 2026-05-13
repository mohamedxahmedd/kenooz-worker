class ChatMediaModel {
  final int id;
  final String collectionName;
  final String fileName;
  final String mimeType;
  final String originalUrl;
  final String previewUrl;

  ChatMediaModel({
    required this.id,
    required this.collectionName,
    required this.fileName,
    required this.mimeType,
    required this.originalUrl,
    required this.previewUrl,
  });

  factory ChatMediaModel.fromJson(Map<String, dynamic> json) {
    return ChatMediaModel(
      id: _parseInt(json['id']),
      collectionName: json['collection_name']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      originalUrl: json['original_url']?.toString() ?? '',
      previewUrl: json['preview_url']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection_name': collectionName,
        'file_name': fileName,
        'mime_type': mimeType,
        'original_url': originalUrl,
        'preview_url': previewUrl,
      };
}
