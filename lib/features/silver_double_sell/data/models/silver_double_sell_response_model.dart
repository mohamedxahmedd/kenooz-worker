import 'package:json_annotation/json_annotation.dart';

part 'silver_double_sell_response_model.g.dart';

@JsonSerializable(createFactory: false)
class SilverDoubleSellResponseModel {
  final String status;
  final String? message;

  SilverDoubleSellResponseModel({
    required this.status,
    this.message,
  });

  factory SilverDoubleSellResponseModel.fromJson(Map<String, dynamic> json) {
    return SilverDoubleSellResponseModel(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$SilverDoubleSellResponseModelToJson(this);
}
