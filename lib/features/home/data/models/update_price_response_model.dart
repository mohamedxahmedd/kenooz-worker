import 'package:json_annotation/json_annotation.dart';

part 'update_price_response_model.g.dart';

@JsonSerializable()
class UpdatePriceResponseModel {
  final String status;
  final String? message;
  final double? usd;
  @JsonKey(name: 'price_21')
  final double? price21;
  final double? price;

  UpdatePriceResponseModel({
    required this.status,
    this.message,
    this.usd,
    this.price21,
    this.price,
  });

  factory UpdatePriceResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdatePriceResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePriceResponseModelToJson(this);
}
