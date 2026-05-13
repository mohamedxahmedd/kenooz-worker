import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_message_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_with_messages_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/send_message_request_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/start_chat_request_model.dart';

class ChatRepo {
  final Dio _dio;

  ChatRepo(this._dio);

  Future<ApiResult<List<ChatModel>>> fetchInbox() async {
    try {
      final response = await _dio.get('chat/worker/inbox');
      final data = response.data as List<dynamic>? ?? [];
      final chats = data
          .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(chats);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ChatModel>>> fetchHistory() async {
    try {
      final response = await _dio.get('chat/worker/history');
      final data = response.data as List<dynamic>? ?? [];
      final chats = data
          .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(chats);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ChatWithMessagesModel>> startChat(
    StartChatRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        'chat/worker/start',
        data: request.toJson(),
      );
      final body = response.data as Map<String, dynamic>;
      return ApiResult.success(ChatWithMessagesModel.fromJson(body));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ChatWithMessagesModel>> fetchMessages(int chatId) async {
    try {
      final response = await _dio.get('chat/worker/$chatId/messages');
      final body = response.data as Map<String, dynamic>;
      return ApiResult.success(ChatWithMessagesModel.fromJson(body));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<ChatMessageModel>> sendMessage(
    SendMessageRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        'message/worker/send',
        data: request.toJson(),
      );
      final body = response.data as Map<String, dynamic>;
      return ApiResult.success(ChatMessageModel.fromJson(body));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> endChat(int chatId) async {
    try {
      final response = await _dio.post('chat/worker/$chatId/end');
      final body = response.data as Map<String, dynamic>;
      final message = body['message']?.toString() ?? '';
      return ApiResult.success(message);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
