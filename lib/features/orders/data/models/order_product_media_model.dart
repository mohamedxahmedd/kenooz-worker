class OrderProductMediaModel {
  final String? id;
  final String? modelType;
  final String? collectionName;
  final String? fileName;
  final String? originalUrl;

  OrderProductMediaModel({
    this.id,
    this.modelType,
    this.collectionName,
    this.fileName,
    this.originalUrl,
  });

  factory OrderProductMediaModel.fromJson(Map<String, dynamic> json) {
    return OrderProductMediaModel(
      id: json['id']?.toString(),
      modelType: json['model_type']?.toString(),
      collectionName: json['collection_name']?.toString(),
      fileName: json['file_name']?.toString(),
      originalUrl: json['original_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model_type': modelType,
        'collection_name': collectionName,
        'file_name': fileName,
        'original_url': originalUrl,
      };
}
