class SilverBuyResponseModel {
  final String status;

  SilverBuyResponseModel({required this.status});

  factory SilverBuyResponseModel.fromJson(Map<String, dynamic> json) {
    return SilverBuyResponseModel(
      status: json['status']?.toString() ?? 'success',
    );
  }
}
