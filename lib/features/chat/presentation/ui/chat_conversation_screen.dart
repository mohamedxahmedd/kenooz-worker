import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/routing/args/chat_conversation_args.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_with_messages_model.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_conversation_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_conversation_state.dart';
import 'widgets/conversation_app_bar.dart';
import 'widgets/conversation_ended_banner.dart';
import 'widgets/conversation_error.dart';
import 'widgets/conversation_input_bar.dart';
import 'widgets/conversation_loading.dart';
import 'widgets/conversation_messages_list.dart';
import 'widgets/end_chat_confirm_dialog.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatConversationArgs args;

  const ChatConversationScreen({super.key, required this.args});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatConversationCubit>().openChatWithClient(
          widget.args.clientId,
          existingChatId: widget.args.chatId,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmEndChat() async {
    final confirmed = await EndChatConfirmDialog.show(context);
    if (!confirmed || !mounted) return;
    context.read<ChatConversationCubit>().endChat();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ChatConversationCubit, ChatConversationState>(
      listenWhen: (previous, current) => current.maybeWhen(
        endChatSuccess: () => true,
        actionError: (_) => true,
        success: (_, __, isEnding) {
          final wasEnding = previous.maybeWhen(
            success: (_, __, wasEnding) => wasEnding,
            orElse: () => false,
          );
          return isEnding != wasEnding;
        },
        orElse: () => false,
      ),
      listener: (context, state) {
        state.whenOrNull(
          success: (_, __, isEnding) {
            if (isEnding) {
              EasyLoading.show();
            } else {
              EasyLoading.dismiss();
            }
          },
          endChatSuccess: () {
            EasyLoading.dismiss();
            successSnackBar(
              msg: 'common.actionCompletedSuccessfully'.tr(),
              context: context,
            );
          },
          actionError: (messages) {
            EasyLoading.dismiss();
            failureSnackBar(msg: messages.join('\n'), context: context);
          },
        );
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkThemeBackgroundColor
            : AppColors.backGroundColorLight,
        body: BlocBuilder<ChatConversationCubit, ChatConversationState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => SafeArea(
                child: Column(
                  children: [
                    ConversationAppBar(
                      clientName: widget.args.clientName ?? '',
                      clientAvatarUrl: widget.args.clientAvatarUrl,
                      isEnded: false,
                      canEnd: false,
                      onBack: () => Navigator.of(context).pop(),
                      onEndChat: () {},
                    ),
                    const Expanded(child: ConversationLoading()),
                  ],
                ),
              ),
              error: (messages) => SafeArea(
                child: Column(
                  children: [
                    ConversationAppBar(
                      clientName: widget.args.clientName ?? '',
                      clientAvatarUrl: widget.args.clientAvatarUrl,
                      isEnded: false,
                      canEnd: false,
                      onBack: () => Navigator.of(context).pop(),
                      onEndChat: () {},
                    ),
                    Expanded(
                      child: ConversationError(
                        message: messages.join('\n'),
                        onRetry: () => context
                            .read<ChatConversationCubit>()
                            .openChatWithClient(
                              widget.args.clientId,
                              existingChatId: widget.args.chatId,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              success: (chat, isSending, _) => _buildSuccess(
                context: context,
                chat: chat,
                isSending: isSending,
              ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccess({
    required BuildContext context,
    required ChatWithMessagesModel chat,
    required bool isSending,
  }) {
    final cubit = context.read<ChatConversationCubit>();
    final clientName = (chat.client?.name ?? widget.args.clientName ?? '')
            .trim()
            .isEmpty
        ? 'chat.unknownClient'.tr()
        : (chat.client?.name ?? widget.args.clientName!);

    return Column(
      children: [
        ConversationAppBar(
          clientName: clientName,
          clientAvatarUrl:
              chat.client?.profileImageUrl ?? widget.args.clientAvatarUrl,
          isEnded: chat.isEnded,
          canEnd: true,
          onBack: () => Navigator.of(context).pop(),
          onEndChat: _confirmEndChat,
        ),
        Expanded(
          child: ConversationMessagesList(
            messages: chat.messages,
            scrollController: _scrollController,
          ),
        ),
        if (chat.isEnded)
          ConversationEndedBanner(chat: chat)
        else
          ConversationInputBar(
            controller: cubit.messageController,
            onSend: cubit.sendMessage,
            isSending: isSending,
          ),
      ],
    );
  }
}
