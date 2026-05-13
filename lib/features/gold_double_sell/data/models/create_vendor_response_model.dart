import 'package:json_annotation/json_annotation.dart';

part 'create_vendor_response_model.g.dart';

@JsonSerializable(createFactory: false)
class CreateVendorResponseModel {
  final int id;
  final String name;
  final int caratId;
  final int currencyId;
  final String phone;
  final String notes;

  CreateVendorResponseModel({
    required this.id,
    required this.name,
    required this.caratId,
    required this.currencyId,
    required this.phone,
    required this.notes,
  });

  factory CreateVendorResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateVendorResponseModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      caratId: _parseInt(json['carat_id']),
      currencyId: _parseInt(json['currency_id']),
      phone: json['phone']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
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

  Map<String, dynamic> toJson() => _$CreateVendorResponseModelToJson(this);
}
