import 'package:json_annotation/json_annotation.dart';
part 'media_model.g.dart';

@JsonSerializable()
class Media {
  dynamic id;
  @JsonKey(name: 'model_type')
  String modelType;
  @JsonKey(name: 'model_id')
  dynamic modelId;
  @JsonKey(name: 'collection_name')
  String collectionName;
  String name;
  @JsonKey(name: 'file_name')
  String fileName;
  @JsonKey(name: 'mime_type')
  String mimeType;
  String disk;
  dynamic size;
  @JsonKey(name: 'original_url')
  String originalUrl;

  Media(
      {required this.id,
      required this.modelId,
      required this.modelType,
      required this.collectionName,
      required this.name,
      required this.fileName,
      required this.mimeType,
      required this.disk,
      required this.size,
      required this.originalUrl});
  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);
}
