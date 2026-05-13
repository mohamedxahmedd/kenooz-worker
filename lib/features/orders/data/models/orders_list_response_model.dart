import 'order_model.dart';

class OrdersListResponseModel {
  final String status;
  final List<OrderModel> orders;

  OrdersListResponseModel({
    required this.status,
    required this.orders,
  });

  factory OrdersListResponseModel.fromJson(Map<String, dynamic> json) {
    return OrdersListResponseModel(
      status: json['status']?.toString() ?? '',
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
