class StartChatRequestModel {
  final int clientId;

  StartChatRequestModel({required this.clientId});

  Map<String, dynamic> toJson() => {'client_id': clientId};
}
