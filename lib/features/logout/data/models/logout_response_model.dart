import 'package:json_annotation/json_annotation.dart';

part 'logout_response_model.g.dart';

@JsonSerializable()
class LogoutResponseModel {
  final String message;

  LogoutResponseModel({required this.message});

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$LogoutResponseModelToJson(this);
}
