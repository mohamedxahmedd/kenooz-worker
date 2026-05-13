// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpResponseModel _$SignUpResponseModelFromJson(Map<String, dynamic> json) =>
    SignUpResponseModel(
      message: json['message'] as String,
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      token: json['token'] as String,
    );

Map<String, dynamic> _$SignUpResponseModelToJson(
  SignUpResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'client': instance.client,
  'token': instance.token,
};

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  gender: json['gender'] as String,
  updatedAt: json['updated_at'] as String,
  createdAt: json['created_at'] as String,
  id: (json['id'] as num).toInt(),
);

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'gender': instance.gender,
  'updated_at': instance.updatedAt,
  'created_at': instance.createdAt,
  'id': instance.id,
};
