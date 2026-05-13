class CreateSilverCaratRequestModel {
  final String carat;
  final double fixed;
  final double price;

  CreateSilverCaratRequestModel({
    required this.carat,
    required this.fixed,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'carat': carat,
        'fixed': fixed,
        'price': price,
      };
}
