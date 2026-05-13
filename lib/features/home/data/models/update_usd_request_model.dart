import 'package:json_annotation/json_annotation.dart';

part 'update_usd_request_model.g.dart';

@JsonSerializable()
class UpdateUsdRequestModel {
  final double price;

  UpdateUsdRequestModel({required this.price});

  factory UpdateUsdRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateUsdRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUsdRequestModelToJson(this);
}
