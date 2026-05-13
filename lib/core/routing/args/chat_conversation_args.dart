class ChatConversationArgs {
  final int clientId;
  final int? chatId;
  final String? clientName;
  final String? clientAvatarUrl;

  ChatConversationArgs({
    required this.clientId,
    this.chatId,
    this.clientName,
    this.clientAvatarUrl,
  });
}
