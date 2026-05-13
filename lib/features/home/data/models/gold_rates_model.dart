import 'package:json_annotation/json_annotation.dart';
import 'package:kenooz_worker_app/features/home/data/models/carat_model.dart';

part 'gold_rates_model.g.dart';

@JsonSerializable()
class GoldRatesModel {
  final List<CaratModel> carats;

  GoldRatesModel({required this.carats});

  factory GoldRatesModel.fromJson(Map<String, dynamic> json) =>
      _$GoldRatesModelFromJson(json);
  Map<String, dynamic> toJson() => _$GoldRatesModelToJson(this);
}
