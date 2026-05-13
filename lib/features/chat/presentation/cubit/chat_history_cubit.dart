import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'package:kenooz_worker_app/features/chat/data/repo/chat_repo.dart';
import 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState<List<ChatModel>>> {
  final ChatRepo _repo;

  ChatHistoryCubit(this._repo) : super(const ChatHistoryState.initial());

  Future<void> fetchHistory() async {
    emit(const ChatHistoryState.loading());
    final response = await _repo.fetchHistory();
    if (isClosed) return;
    response.when(
      success: (chats) => emit(ChatHistoryState.success(chats)),
      failure: (error) => emit(
        ChatHistoryState.error(messages: _extractMessages(error.errorModel)),
      ),
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
