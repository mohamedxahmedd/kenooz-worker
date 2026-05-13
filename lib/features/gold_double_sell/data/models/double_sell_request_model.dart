class DoubleSellRequestModel {
  final int clientId;
  final int workerId;
  final double total;
  final double tax;
  final String notes;
  final List<Map<String, dynamic>> allAccounts;
  final List<Map<String, dynamic>> insideProducts;
  final List<Map<String, dynamic>> outsideProducts;
  final List<Map<String, dynamic>> boxProducts;
  final List<Map<String, dynamic>> buyGoldProducts;
  final List<Map<String, dynamic>> deductionAccounts;

  DoubleSellRequestModel({
    required this.clientId,
    required this.workerId,
    required this.total,
    required this.tax,
    required this.notes,
    required this.allAccounts,
    required this.insideProducts,
    required this.outsideProducts,
    required this.boxProducts,
    required this.buyGoldProducts,
    required this.deductionAccounts,
  });

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'worker_id': workerId,
        'total': total,
        'tax': tax,
        'notes': notes,
        'all_accounts': allAccounts,
        'insideProducts': insideProducts,
        'outsideProducts': outsideProducts,
        'boxProducts': boxProducts,
        'buyGoldProducts': buyGoldProducts,
        'deduction_accounts': deductionAccounts,
      };
}
