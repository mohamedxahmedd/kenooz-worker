// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaratModel _$CaratModelFromJson(Map<String, dynamic> json) => CaratModel(
  id: (json['id'] as num).toInt(),
  carat: json['carat'] as String,
  fixed: (json['fixed'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$CaratModelToJson(CaratModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'carat': instance.carat,
      'fixed': instance.fixed,
      'price': instance.price,
    };
