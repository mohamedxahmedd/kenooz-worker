import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_message_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_with_messages_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/send_message_request_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/start_chat_request_model.dart';
import 'package:kenooz_worker_app/features/chat/data/repo/chat_repo.dart';
import 'chat_conversation_state.dart';

class ChatConversationCubit extends Cubit<ChatConversationState> {
  final ChatRepo _repo;

  final TextEditingController messageController = TextEditingController();

  ChatWithMessagesModel? _chat;
  Timer? _pollTimer;

  static const Duration _pollInterval = Duration(seconds: 5);

  ChatConversationCubit(this._repo)
      : super(const ChatConversationState.initial());

  ChatWithMessagesModel? get chat => _chat;

  Future<void> openChatWithClient(int clientId, {int? existingChatId}) async {
    emit(const ChatConversationState.loading());
    if (existingChatId != null) {
      await _loadMessages(existingChatId);
      return;
    }
    final response = await _repo.startChat(
      StartChatRequestModel(clientId: clientId),
    );
    if (isClosed) return;
    response.when(
      success: (chat) {
        _chat = chat;
        emit(ChatConversationState.success(chat: chat));
        if (!chat.isEnded) startMessagePolling();
      },
      failure: (error) => emit(
        ChatConversationState.error(messages: _extractMessages(error.errorModel)),
      ),
    );
  }

  Future<void> _loadMessages(int chatId) async {
    final response = await _repo.fetchMessages(chatId);
    if (isClosed) return;
    response.when(
      success: (chat) {
        _chat = chat;
        emit(ChatConversationState.success(chat: chat));
        if (!chat.isEnded) startMessagePolling();
      },
      failure: (error) => emit(
        ChatConversationState.error(messages: _extractMessages(error.errorModel)),
      ),
    );
  }

  Future<void> refreshMessages({bool silent = false}) async {
    final chat = _chat;
    if (chat == null) return;
    final response = await _repo.fetchMessages(chat.id);
    if (isClosed) return;
    response.when(
      success: (updated) {
        _chat = updated;
        emit(ChatConversationState.success(chat: updated));
        if (updated.isEnded) stopMessagePolling();
      },
      failure: (error) {
        if (silent) return;
        emit(ChatConversationState.error(
          messages: _extractMessages(error.errorModel),
        ));
      },
    );
  }

  Future<void> sendMessage() async {
    final chat = _chat;
    if (chat == null || chat.isEnded) return;
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    emit(ChatConversationState.success(chat: chat, isSending: true));

    final response = await _repo.sendMessage(
      SendMessageRequestModel(chatId: chat.id, message: text),
    );
    if (isClosed) return;
    response.when(
      success: (newMessage) {
        messageController.clear();
        final updated = chat.copyWith(
          messages: List<ChatMessageModel>.from(chat.messages)..add(newMessage),
        );
        _chat = updated;
        emit(ChatConversationState.success(chat: updated));
      },
      failure: (error) {
        emit(ChatConversationState.success(chat: chat));
        emit(ChatConversationState.actionError(
          messages: _extractMessages(error.errorModel),
        ));
        emit(ChatConversationState.success(chat: chat));
      },
    );
  }

  Future<void> endChat() async {
    final chat = _chat;
    if (chat == null || chat.isEnded) return;

    emit(ChatConversationState.success(chat: chat, isEnding: true));

    final response = await _repo.endChat(chat.id);
    if (isClosed) return;
    response.when(
      success: (_) {
        stopMessagePolling();
        final updated = chat.copyWith(isEnded: true);
        _chat = updated;
        emit(const ChatConversationState.endChatSuccess());
        emit(ChatConversationState.success(chat: updated));
      },
      failure: (error) {
        emit(ChatConversationState.success(chat: chat));
        emit(ChatConversationState.actionError(
          messages: _extractMessages(error.errorModel),
        ));
        emit(ChatConversationState.success(chat: chat));
      },
    );
  }

  void startMessagePolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      refreshMessages(silent: true);
    });
  }

  void stopMessagePolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    stopMessagePolling();
    messageController.dispose();
    return super.close();
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
