import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String email;
  final String password;
  @JsonKey(name: 'device_name')
  final String deviceName;
  @JsonKey(name: 'device_token')
  final String deviceToken;
  LoginRequestModel({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.deviceToken,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
