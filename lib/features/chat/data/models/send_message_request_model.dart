class SendMessageRequestModel {
  final int chatId;
  final String message;

  SendMessageRequestModel({required this.chatId, required this.message});

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'message': message,
      };
}
