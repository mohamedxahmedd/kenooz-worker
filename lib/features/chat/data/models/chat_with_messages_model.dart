import 'chat_client_model.dart';
import 'chat_message_model.dart';

class ChatWithMessagesModel {
  final int id;
  final int workerId;
  final int clientId;
  final String? status;
  final bool isEnded;
  final int? rating;
  final String? note;
  final bool? isSolved;
  final List<ChatMessageModel> messages;
  final ChatClientModel? client;
  final String createdAt;
  final String updatedAt;

  ChatWithMessagesModel({
    required this.id,
    required this.workerId,
    required this.clientId,
    this.status,
    required this.isEnded,
    this.rating,
    this.note,
    this.isSolved,
    required this.messages,
    this.client,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatWithMessagesModel.fromJson(Map<String, dynamic> json) {
    return ChatWithMessagesModel(
      id: _parseInt(json['id']),
      workerId: _parseInt(json['worker_id']),
      clientId: _parseInt(json['client_id']),
      status: json['status']?.toString(),
      isEnded: _parseBool(json['is_ended']),
      rating: json['rating'] != null ? _parseInt(json['rating']) : null,
      note: json['note']?.toString(),
      isSolved: json['is_solved'] != null ? _parseBool(json['is_solved']) : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      client: json['client'] != null
          ? ChatClientModel.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  ChatWithMessagesModel copyWith({
    bool? isEnded,
    List<ChatMessageModel>? messages,
  }) {
    return ChatWithMessagesModel(
      id: id,
      workerId: workerId,
      clientId: clientId,
      status: status,
      isEnded: isEnded ?? this.isEnded,
      rating: rating,
      note: note,
      isSolved: isSolved,
      messages: messages ?? this.messages,
      client: client,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
}
