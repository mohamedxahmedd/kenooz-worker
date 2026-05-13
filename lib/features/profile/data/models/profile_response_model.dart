import 'package:json_annotation/json_annotation.dart';

part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel {
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
  final String? image;
  @JsonKey(name: 'no_of_success_shipments')
  final int noOfSuccessShipments;
  @JsonKey(name: 'no_of_failed_shipments')
  final int noOfFailedShipments;
  @JsonKey(name: 'no_of_pending_shipments')
  final int noOfPendingShipments;

  ProfileResponseModel({
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
    this.image,
    required this.noOfSuccessShipments,
    required this.noOfFailedShipments,
    required this.noOfPendingShipments,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);
}
