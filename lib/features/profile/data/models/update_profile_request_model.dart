import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request_model.g.dart';

@JsonSerializable(createFactory: false)
class UpdateProfileRequestModel {
  final String? name;
  final String? phone;
  final String? email;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  UpdateProfileRequestModel({
    this.name,
    this.phone,
    this.email,
    this.deviceToken,
  });

  Map<String, dynamic> toJson() => _$UpdateProfileRequestModelToJson(this);
}
