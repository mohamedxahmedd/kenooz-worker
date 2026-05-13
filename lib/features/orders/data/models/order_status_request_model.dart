class OrderStatusRequestModel {
  final int id;
  final String status;

  OrderStatusRequestModel({required this.id, required this.status});

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
      };
}
