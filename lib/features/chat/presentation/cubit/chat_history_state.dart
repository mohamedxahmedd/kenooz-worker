import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';

part 'chat_history_state.freezed.dart';

@freezed
class ChatHistoryState<T> with _$ChatHistoryState<T> {
  const factory ChatHistoryState.initial() = _Initial;
  const factory ChatHistoryState.loading() = Loading;
  const factory ChatHistoryState.success(T data) = Success<T>;
  const factory ChatHistoryState.error({required List<String> messages}) = Error;
}

typedef ChatHistoryListState = ChatHistoryState<List<ChatModel>>;
