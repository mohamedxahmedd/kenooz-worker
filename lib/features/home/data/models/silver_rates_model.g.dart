// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'silver_rates_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SilverRatesModel _$SilverRatesModelFromJson(Map<String, dynamic> json) =>
    SilverRatesModel(
      carats: (json['carats'] as List<dynamic>)
          .map((e) => CaratModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SilverRatesModelToJson(SilverRatesModel instance) =>
    <String, dynamic>{'carats': instance.carats};
