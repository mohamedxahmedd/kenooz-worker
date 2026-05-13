import 'chat_media_model.dart';

class ChatClientModel {
  final int id;
  final String name;
  final String? phone;
  final List<ChatMediaModel> media;

  ChatClientModel({
    required this.id,
    required this.name,
    this.phone,
    required this.media,
  });

  factory ChatClientModel.fromJson(Map<String, dynamic> json) {
    return ChatClientModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => ChatMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String? get profileImageUrl {
    if (media.isEmpty) return null;
    final url = media.first.originalUrl.trim();
    return url.isEmpty ? null : url;
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'media': media.map((e) => e.toJson()).toList(),
      };
}
