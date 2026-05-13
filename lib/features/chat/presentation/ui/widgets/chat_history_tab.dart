import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_history_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_history_state.dart';
import 'chat_history_tile.dart';
import 'chat_list_empty.dart';
import 'chat_list_error.dart';
import 'chat_list_loading.dart';

class ChatHistoryTab extends StatelessWidget {
  final void Function(ChatModel chat) onChatTap;

  const ChatHistoryTab({super.key, required this.onChatTap});

  Future<void> _refresh(BuildContext context) async {
    await context.read<ChatHistoryCubit>().fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatHistoryCubit, ChatHistoryState<List<ChatModel>>>(
      builder: (context, state) {
        return state.maybeWhen(
          initial: () => const ChatListLoading(),
          loading: () => const ChatListLoading(),
          success: (chats) => _ClosedChatList(
            chats: chats,
            onRefresh: () => _refresh(context),
            onChatTap: onChatTap,
            emptyMessage: 'chat.empty.history'.tr(),
          ),
          error: (messages) => ChatListError(
            message: messages.join('\n'),
            onRetry: () => context.read<ChatHistoryCubit>().fetchHistory(),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ClosedChatList extends StatelessWidget {
  final List<ChatModel> chats;
  final Future<void> Function() onRefresh;
  final void Function(ChatModel chat) onChatTap;
  final String emptyMessage;

  const _ClosedChatList({
    required this.chats,
    required this.onRefresh,
    required this.onChatTap,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.darkBrown,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
          children: [
            SizedBox(height: 64.h),
            ChatListEmpty(
              message: emptyMessage,
              icon: Icons.history_rounded,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.darkBrown,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        itemCount: chats.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, index) {
          final chat = chats[index];
          return ChatHistoryTile(chat: chat, onTap: () => onChatTap(chat));
        },
      ),
    );
  }
}
