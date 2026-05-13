import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';

part 'chat_inbox_state.freezed.dart';

@freezed
class ChatInboxState<T> with _$ChatInboxState<T> {
  const factory ChatInboxState.initial() = _Initial;
  const factory ChatInboxState.loading() = Loading;
  const factory ChatInboxState.success(T data) = Success<T>;
  const factory ChatInboxState.error({required List<String> messages}) = Error;
}

typedef ChatListState = ChatInboxState<List<ChatModel>>;
