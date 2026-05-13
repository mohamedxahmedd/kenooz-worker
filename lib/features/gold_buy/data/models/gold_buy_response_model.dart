class GoldBuyResponseModel {
  final String status;

  GoldBuyResponseModel({required this.status});

  factory GoldBuyResponseModel.fromJson(Map<String, dynamic> json) {
    return GoldBuyResponseModel(
      status: json['status']?.toString() ?? 'success',
    );
  }
}
