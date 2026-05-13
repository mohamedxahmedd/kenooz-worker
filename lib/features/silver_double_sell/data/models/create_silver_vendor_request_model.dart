class CreateSilverVendorRequestModel {
  final String name;
  final int caratId;
  final int currencyId;
  final String? phone;
  final String? notes;

  CreateSilverVendorRequestModel({
    required this.name,
    required this.caratId,
    required this.currencyId,
    this.phone,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'carat_id': caratId,
        'currency_id': currencyId,
        'phone': phone,
        'notes': notes,
      };
}
