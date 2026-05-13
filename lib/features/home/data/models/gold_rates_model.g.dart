// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_rates_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoldRatesModel _$GoldRatesModelFromJson(Map<String, dynamic> json) =>
    GoldRatesModel(
      carats: (json['carats'] as List<dynamic>)
          .map((e) => CaratModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GoldRatesModelToJson(GoldRatesModel instance) =>
    <String, dynamic>{'carats': instance.carats};
