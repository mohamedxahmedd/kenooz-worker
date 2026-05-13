// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
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
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
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
};
