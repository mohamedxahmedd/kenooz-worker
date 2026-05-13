import 'chat_client_model.dart';
import 'chat_message_model.dart';

class ChatModel {
  final int id;
  final int workerId;
  final int clientId;
  final String? status;
  final bool isEnded;
  final int? rating;
  final String? note;
  final bool? isSolved;
  final int unreadCount;
  final ChatMessageModel? latestMessage;
  final ChatClientModel? client;
  final String createdAt;
  final String updatedAt;

  ChatModel({
    required this.id,
    required this.workerId,
    required this.clientId,
    this.status,
    required this.isEnded,
    this.rating,
    this.note,
    this.isSolved,
    required this.unreadCount,
    this.latestMessage,
    this.client,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: _parseInt(json['id']),
      workerId: _parseInt(json['worker_id']),
      clientId: _parseInt(json['client_id']),
      status: json['status']?.toString(),
      isEnded: _parseBool(json['is_ended']),
      rating: json['rating'] != null ? _parseInt(json['rating']) : null,
      note: json['note']?.toString(),
      isSolved: json['is_solved'] != null ? _parseBool(json['is_solved']) : null,
      unreadCount: json['unread_count'] != null
          ? _parseInt(json['unread_count'])
          : 0,
      latestMessage: json['latest_message'] != null
          ? ChatMessageModel.fromJson(
              json['latest_message'] as Map<String, dynamic>,
            )
          : null,
      client: json['client'] != null
          ? ChatClientModel.fromJson(json['client'] as Map<String, dynamic>)
          : null,
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
        'worker_id': workerId,
        'client_id': clientId,
        'status': status,
        'is_ended': isEnded,
        'rating': rating,
        'note': note,
        'is_solved': isSolved,
        'unread_count': unreadCount,
        'latest_message': latestMessage?.toJson(),
        'client': client?.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
