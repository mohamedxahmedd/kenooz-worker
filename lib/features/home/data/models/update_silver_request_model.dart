import 'package:json_annotation/json_annotation.dart';

part 'update_silver_request_model.g.dart';

@JsonSerializable()
class UpdateSilverRequestModel {
  final double price;

  UpdateSilverRequestModel({required this.price});

  factory UpdateSilverRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateSilverRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSilverRequestModelToJson(this);
}
