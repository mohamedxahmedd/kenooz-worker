// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
  id: json['id'],
  modelId: json['model_id'],
  modelType: json['model_type'] as String,
  collectionName: json['collection_name'] as String,
  name: json['name'] as String,
  fileName: json['file_name'] as String,
  mimeType: json['mime_type'] as String,
  disk: json['disk'] as String,
  size: json['size'],
  originalUrl: json['original_url'] as String,
);

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'id': instance.id,
  'model_type': instance.modelType,
  'model_id': instance.modelId,
  'collection_name': instance.collectionName,
  'name': instance.name,
  'file_name': instance.fileName,
  'mime_type': instance.mimeType,
  'disk': instance.disk,
  'size': instance.size,
  'original_url': instance.originalUrl,
};
