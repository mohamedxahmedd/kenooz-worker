import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  @JsonKey(name: 'shop_id')
  final int shopId;
  final String name;
  final String phone;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'device_token')
  final String? deviceToken;
  @JsonKey(name: 'is_online')
  final int isOnline;
  @JsonKey(name: 'is_admin')
  final int isAdmin;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final String role;

  UserModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.email,
    this.emailVerifiedAt,
    this.deviceToken,
    required this.isOnline,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
