import 'order_item_model.dart';
import 'order_client_model.dart';
import 'order_product_media_model.dart';

class OrderModel {
  final int id;
  final int clientId;
  final int addressId;
  final String name;
  final String status;
  final double total;
  final double shippingFee;
  final String? promo;
  final double? discount;
  final int isPaid;
  final int? isAccepted;
  final int isSent;
  final String pickupType;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final List<OrderItemModel> orderItems;
  final OrderClientModel? client;
  final List<OrderProductMediaModel> media;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.addressId,
    required this.name,
    required this.status,
    required this.total,
    required this.shippingFee,
    this.promo,
    this.discount,
    required this.isPaid,
    this.isAccepted,
    required this.isSent,
    required this.pickupType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    this.client,
    required this.media,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _parseInt(json['id']),
      clientId: _parseInt(json['client_id']),
      addressId: _parseInt(json['address_id']),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      total: _parseDouble(json['total']),
      shippingFee: _parseDouble(json['shipping_fee']),
      promo: json['promo']?.toString(),
      discount: json['discount'] != null ? _parseDouble(json['discount']) : null,
      isPaid: _parseInt(json['is_paid']),
      isAccepted: json['is_accepted'] != null ? _parseInt(json['is_accepted']) : null,
      isSent: _parseInt(json['is_sent']),
      pickupType: json['pickup_type']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      client: json['client'] != null
          ? OrderClientModel.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => OrderProductMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
        'client_id': clientId,
        'address_id': addressId,
        'name': name,
        'status': status,
        'total': total,
        'shipping_fee': shippingFee,
        'promo': promo,
        'discount': discount,
        'is_paid': isPaid,
        'is_accepted': isAccepted,
        'is_sent': isSent,
        'pickup_type': pickupType,
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'order_items': orderItems.map((e) => e.toJson()).toList(),
        'client': client?.toJson(),
        'media': media.map((e) => e.toJson()).toList(),
      };
}
