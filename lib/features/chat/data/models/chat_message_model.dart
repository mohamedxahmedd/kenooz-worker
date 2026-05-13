class ChatMessageModel {
  final int id;
  final int chatId;
  final String from;
  final String to;
  final String message;
  final bool isRead;
  final String createdAt;
  final String updatedAt;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.from,
    required this.to,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFromWorker => from == 'worker';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _parseInt(json['id']),
      chatId: _parseInt(json['chat_id']),
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: _parseBool(json['is_read']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chat_id': chatId,
        'from': from,
        'to': to,
        'message': message,
        'is_read': isRead,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
