class UnhangResponseModel {
  final String status;
  final String message;

  UnhangResponseModel({required this.status, required this.message});

  factory UnhangResponseModel.fromJson(Map<String, dynamic> json) {
    return UnhangResponseModel(
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? '',
    );
  }
}
