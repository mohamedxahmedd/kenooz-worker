import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_with_messages_model.dart';

part 'chat_conversation_state.freezed.dart';

@freezed
class ChatConversationState with _$ChatConversationState {
  const factory ChatConversationState.initial() = _Initial;
  const factory ChatConversationState.loading() = Loading;
  const factory ChatConversationState.success({
    required ChatWithMessagesModel chat,
    @Default(false) bool isSending,
    @Default(false) bool isEnding,
  }) = Success;
  const factory ChatConversationState.error({required List<String> messages}) =
      Error;
  const factory ChatConversationState.endChatSuccess() = EndChatSuccess;
  const factory ChatConversationState.actionError({
    required List<String> messages,
  }) = ActionError;
}
