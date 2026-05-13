import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';

class SilverRatesModel {
  final List<SilverCaratModel> carats;

  SilverRatesModel({required this.carats});

  factory SilverRatesModel.fromJson(Map<String, dynamic> json) {
    final caratsJson = json['carats'] as List<dynamic>? ?? [];
    return SilverRatesModel(
      carats: caratsJson
          .map((e) => SilverCaratModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
