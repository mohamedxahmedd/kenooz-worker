enum InvoiceType {
  gold('gold'),
  silver('silver'),
  diamond('diamond'),
  stone('stone'),
  goldBuy('gold_buy'),
  silverBuy('silver_buy');

  const InvoiceType(this.pathSegment);

  final String pathSegment;
}
