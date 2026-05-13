import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'package:kenooz_worker_app/features/chat/data/repo/chat_repo.dart';
import 'chat_inbox_state.dart';

class ChatInboxCubit extends Cubit<ChatInboxState<List<ChatModel>>> {
  final ChatRepo _repo;
  Timer? _pollTimer;

  static const Duration _pollInterval = Duration(seconds: 10);

  ChatInboxCubit(this._repo) : super(const ChatInboxState.initial());

  Future<void> fetchInbox({bool silent = false}) async {
    if (!silent) emit(const ChatInboxState.loading());
    final response = await _repo.fetchInbox();
    if (isClosed) return;
    response.when(
      success: (chats) => emit(ChatInboxState.success(chats)),
      failure: (error) {
        if (silent) return;
        emit(ChatInboxState.error(messages: _extractMessages(error.errorModel)));
      },
    );
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      fetchInbox(silent: true);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    stopPolling();
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
