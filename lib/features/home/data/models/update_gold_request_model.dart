import 'package:json_annotation/json_annotation.dart';

part 'update_gold_request_model.g.dart';

@JsonSerializable()
class UpdateGoldRequestModel {
  @JsonKey(name: 'price_21')
  final double price21;

  UpdateGoldRequestModel({required this.price21});

  factory UpdateGoldRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoldRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateGoldRequestModelToJson(this);
}
