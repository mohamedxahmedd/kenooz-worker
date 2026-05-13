// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponseModel _$ProfileResponseModelFromJson(
  Map<String, dynamic> json,
) => ProfileResponseModel(
  id: (json['id'] as num).toInt(),
  shopId: (json['shop_id'] as num).toInt(),
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  emailVerifiedAt: json['email_verified_at'] as String?,
  deviceToken: json['device_token'] as String?,
  isOnline: (json['is_online'] as num).toInt(),
  isAdmin: (json['is_admin'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  role: json['role'] as String,
  image: json['image'] as String?,
  noOfSuccessShipments: (json['no_of_success_shipments'] as num).toInt(),
  noOfFailedShipments: (json['no_of_failed_shipments'] as num).toInt(),
  noOfPendingShipments: (json['no_of_pending_shipments'] as num).toInt(),
);

Map<String, dynamic> _$ProfileResponseModelToJson(
  ProfileResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'email_verified_at': instance.emailVerifiedAt,
  'device_token': instance.deviceToken,
  'is_online': instance.isOnline,
  'is_admin': instance.isAdmin,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'role': instance.role,
  'image': instance.image,
  'no_of_success_shipments': instance.noOfSuccessShipments,
  'no_of_failed_shipments': instance.noOfFailedShipments,
  'no_of_pending_shipments': instance.noOfPendingShipments,
};
