import 'order_product_model.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final String productableType;
  final int productableId;
  final int shopId;
  final String? domainName;
  final int qty;
  final double price;
  final double subtotal;
  final int? currencyId;
  final OrderProductModel? product;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productableType,
    required this.productableId,
    required this.shopId,
    this.domainName,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.currencyId,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['order_id']),
      productableType: json['productable_type']?.toString() ?? '',
      productableId: _parseInt(json['productable_id']),
      shopId: _parseInt(json['shop_id']),
      domainName: json['domain_name']?.toString(),
      qty: _parseInt(json['qty']),
      price: _parseDouble(json['price']),
      subtotal: _parseDouble(json['subtotal']),
      currencyId: json['currency_id'] != null ? _parseInt(json['currency_id']) : null,
      // Real API response uses 'productable' key, not 'product'
      product: json['productable'] != null
          ? OrderProductModel.fromJson(json['productable'] as Map<String, dynamic>)
          : null,
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

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid double value: $value');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'productable_type': productableType,
        'productable_id': productableId,
        'shop_id': shopId,
        'domain_name': domainName,
        'qty': qty,
        'price': price,
        'subtotal': subtotal,
        'currency_id': currencyId,
        'product': product?.toJson(),
      };
}
