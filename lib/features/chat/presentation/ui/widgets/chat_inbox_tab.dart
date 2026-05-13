import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_inbox_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_inbox_state.dart';
import 'chat_inbox_tile.dart';
import 'chat_list_empty.dart';
import 'chat_list_error.dart';
import 'chat_list_loading.dart';

class ChatInboxTab extends StatelessWidget {
  final void Function(ChatModel chat) onChatTap;

  const ChatInboxTab({super.key, required this.onChatTap});

  Future<void> _refresh(BuildContext context) async {
    await context.read<ChatInboxCubit>().fetchInbox(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatInboxCubit, ChatInboxState<List<ChatModel>>>(
      builder: (context, state) {
        return state.maybeWhen(
          initial: () => const ChatListLoading(),
          loading: () => const ChatListLoading(),
          success: (chats) => _ChatList(
            chats: chats,
            onRefresh: () => _refresh(context),
            onChatTap: onChatTap,
            emptyMessage: 'chat.empty.active'.tr(),
            emptyIcon: Icons.forum_outlined,
          ),
          error: (messages) => ChatListError(
            message: messages.join('\n'),
            onRetry: () => context.read<ChatInboxCubit>().fetchInbox(),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatModel> chats;
  final Future<void> Function() onRefresh;
  final void Function(ChatModel chat) onChatTap;
  final String emptyMessage;
  final IconData emptyIcon;

  const _ChatList({
    required this.chats,
    required this.onRefresh,
    required this.onChatTap,
    required this.emptyMessage,
    required this.emptyIcon,
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
            ChatListEmpty(message: emptyMessage, icon: emptyIcon),
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
          return ChatInboxTile(chat: chat, onTap: () => onChatTap(chat));
        },
      ),
    );
  }
}
