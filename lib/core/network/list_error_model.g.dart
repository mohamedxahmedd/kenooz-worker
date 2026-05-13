// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_error_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListErrorModel _$ListErrorModelFromJson(Map<String, dynamic> json) =>
    ListErrorModel(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ListErrorModelToJson(ListErrorModel instance) =>
    <String, dynamic>{'messages': instance.messages};
