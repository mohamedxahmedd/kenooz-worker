// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_price_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePriceResponseModel _$UpdatePriceResponseModelFromJson(
  Map<String, dynamic> json,
) => UpdatePriceResponseModel(
  status: json['status'] as String,
  message: json['message'] as String?,
  usd: (json['usd'] as num?)?.toDouble(),
  price21: (json['price_21'] as num?)?.toDouble(),
  price: (json['price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UpdatePriceResponseModelToJson(
  UpdatePriceResponseModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'usd': instance.usd,
  'price_21': instance.price21,
  'price': instance.price,
};
