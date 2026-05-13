class UnhangRequestModel {
  final int goldId;

  UnhangRequestModel({required this.goldId});

  Map<String, dynamic> toJson() => {'gold_id': goldId};
}
