import 'package:json_annotation/json_annotation.dart';

part 'silver_vendor_model.g.dart';

@JsonSerializable(createFactory: false)
class SilverVendorModel {
  final int id;
  final String name;
  final int caratId;
  final int currencyId;

  SilverVendorModel({
    required this.id,
    required this.name,
    required this.caratId,
    required this.currencyId,
  });

  factory SilverVendorModel.fromJson(Map<String, dynamic> json) {
    return SilverVendorModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      caratId: _parseInt(json['carat_id']),
      currencyId: _parseInt(json['currency_id']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    throw FormatException('Invalid int value: $value');
  }

  Map<String, dynamic> toJson() => _$SilverVendorModelToJson(this);
}
