class OrderActionRequestModel {
  final int id;

  OrderActionRequestModel({required this.id});

  Map<String, dynamic> toJson() => {'id': id};
}
