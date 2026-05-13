import 'package:json_annotation/json_annotation.dart';

part 'usd_rate_model.g.dart';

@JsonSerializable()
class UsdRateModel {
  final double usd;

  UsdRateModel({required this.usd});

  factory UsdRateModel.fromJson(Map<String, dynamic> json) =>
      UsdRateModel(usd: _parseDouble(json['usd']));

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() => _$UsdRateModelToJson(this);
}
