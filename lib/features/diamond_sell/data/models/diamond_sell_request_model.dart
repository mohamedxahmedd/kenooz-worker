class DiamondSellRequestModel {
  final int clientId;
  final int workerId;
  final double total;
  final String? notes;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> allAccounts;

  DiamondSellRequestModel({
    required this.clientId,
    required this.workerId,
    required this.total,
    this.notes,
    required this.products,
    required this.allAccounts,
  });

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'worker_id': workerId,
        'total': total,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'products': products,
        'all_accounts': allAccounts,
      };
}
