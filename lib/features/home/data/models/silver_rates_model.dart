import 'package:json_annotation/json_annotation.dart';
import 'package:kenooz_worker_app/features/home/data/models/carat_model.dart';

part 'silver_rates_model.g.dart';

@JsonSerializable()
class SilverRatesModel {
  final List<CaratModel> carats;

  SilverRatesModel({required this.carats});

  factory SilverRatesModel.fromJson(Map<String, dynamic> json) =>
      _$SilverRatesModelFromJson(json);
  Map<String, dynamic> toJson() => _$SilverRatesModelToJson(this);
}
