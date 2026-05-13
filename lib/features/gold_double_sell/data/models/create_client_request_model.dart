class CreateClientRequestModel {
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String clientGender;

  CreateClientRequestModel({
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.clientGender,
  });

  Map<String, dynamic> toJson() => {
        'client_name': clientName,
        'client_phone': clientPhone,
        'client_email': clientEmail,
        'gender': clientGender,
      };
}
