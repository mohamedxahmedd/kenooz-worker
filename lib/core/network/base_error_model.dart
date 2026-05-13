import 'package:json_annotation/json_annotation.dart';

part 'base_error_model.g.dart';

@JsonSerializable()
class BaseErrorModel {
  final String? message;

  BaseErrorModel({this.message});

  factory BaseErrorModel.fromJson(Map<String, dynamic> json) => _$BaseErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseErrorModelToJson(this);
}
