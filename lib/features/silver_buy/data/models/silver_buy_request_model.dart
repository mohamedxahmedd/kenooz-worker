class SilverBuyRequestModel {
  final int workerId;
  final double total;
  final String? notes;
  final int? clientId;
  final int? vendorId;
  final int? sellId;
  final List<Map<String, dynamic>> allAccounts;
  final List<Map<String, dynamic>> products;

  SilverBuyRequestModel({
    required this.workerId,
    required this.total,
    this.notes,
    this.clientId,
    this.vendorId,
    this.sellId,
    required this.allAccounts,
    required this.products,
  });

  Map<String, dynamic> toJson() => {
        'worker_id': workerId,
        'total': total,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'client_id': clientId,
        'vendor_id': vendorId,
        'sell_id': sellId,
        'all_accounts': allAccounts,
        'products': products,
      };
}
