import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_conversation_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_conversation_state.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_history_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_inbox_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/chat_avatar.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/chat_history_tab.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/chat_inbox_tab.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/chat_rating_stars.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/conversation_input_bar.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/conversation_messages_list.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/widgets/end_chat_confirm_dialog.dart';

const Color _accent = Color(0xFFCBA135);

/// Desktop Chat — three-pane: inbox list (left), conversation thread
/// (center), contact + chat details (right). Reuses ChatInboxCubit,
/// ChatHistoryCubit unchanged. A fresh ChatConversationCubit is created
/// per selected chat via `key: ValueKey(chat.id)` so polling restarts
/// cleanly per conversation.
class ChatDesktopScreen extends StatefulWidget {
  const ChatDesktopScreen({super.key});

  @override
  State<ChatDesktopScreen> createState() => _ChatDesktopScreenState();
}

class _ChatDesktopScreenState extends State<ChatDesktopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ChatModel? _selected;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ChatInboxCubit>().fetchInbox();
    context.read<ChatHistoryCubit>().fetchHistory();
    context.read<ChatInboxCubit>().startPolling();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onChatTap(ChatModel chat) {
    setState(() => _selected = chat);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesktopHeader(onRefresh: () {
            context.read<ChatInboxCubit>().fetchInbox(silent: true);
            context.read<ChatHistoryCubit>().fetchHistory();
          }),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1200;
                final inboxPane = _InboxPane(
                  tabController: _tabController,
                  onChatTap: _onChatTap,
                  selectedChatId: _selected?.id,
                );
                if (!wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: inboxPane),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 7,
                        child: _ConversationPaneOrPrompt(
                          selected: _selected,
                          onChatEnded: () =>
                              context.read<ChatInboxCubit>().fetchInbox(),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: inboxPane),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _ConversationPaneOrPrompt(
                        selected: _selected,
                        onChatEnded: () =>
                            context.read<ChatInboxCubit>().fetchInbox(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _selected == null
                          ? const _SelectAPrompt()
                          : _ContactDetailsPane(chat: _selected!),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _accent.withValues(alpha: 0.14),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat.title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'chat.subtitle'.tr(),
                  style: AppFonts.body(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('common.refresh'.tr()),
          ),
        ],
      ),
    );
  }
}

// ─── Inbox pane (tabs) ─────────────────────────────────────────────────────

class _InboxPane extends StatelessWidget {
  const _InboxPane({
    required this.tabController,
    required this.onChatTap,
    required this.selectedChatId,
  });
  final TabController tabController;
  final ValueChanged<ChatModel> onChatTap;
  final int? selectedChatId;

  @override
  Widget build(BuildContext context) {
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'chat.tabs.active'.tr()),
              Tab(text: 'chat.tabs.history'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _SelectedHighlight(
                  selectedChatId: selectedChatId,
                  child: ChatInboxTab(onChatTap: onChatTap),
                ),
                _SelectedHighlight(
                  selectedChatId: selectedChatId,
                  child: ChatHistoryTab(onChatTap: onChatTap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// No-op wrapper for now — kept as a hook for future "highlight selected
/// inbox row" treatment without touching the shared mobile tile widgets.
class _SelectedHighlight extends StatelessWidget {
  const _SelectedHighlight({required this.child, required this.selectedChatId});
  final Widget child;
  final int? selectedChatId;

  @override
  Widget build(BuildContext context) => child;
}

// ─── Conversation pane ─────────────────────────────────────────────────────

class _ConversationPaneOrPrompt extends StatelessWidget {
  const _ConversationPaneOrPrompt({
    required this.selected,
    required this.onChatEnded,
  });
  final ChatModel? selected;
  final VoidCallback onChatEnded;

  @override
  Widget build(BuildContext context) {
    if (selected == null) return const _SelectAPrompt();
    return BlocProvider(
      key: ValueKey('conv-${selected!.id}'),
      create: (_) => ChatConversationCubit(getIt())
        ..openChatWithClient(
          selected!.clientId,
          existingChatId: selected!.id,
        ),
      child: _ConversationPane(
        chat: selected!,
        onChatEnded: onChatEnded,
      ),
    );
  }
}

class _ConversationPane extends StatefulWidget {
  const _ConversationPane({
    required this.chat,
    required this.onChatEnded,
  });
  final ChatModel chat;
  final VoidCallback onChatEnded;

  @override
  State<_ConversationPane> createState() => _ConversationPaneState();
}

class _ConversationPaneState extends State<_ConversationPane> {
  final ScrollController _messagesScrollController = ScrollController();

  @override
  void dispose() {
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ChatConversationCubit, ChatConversationState>(
      listener: (context, state) {
        state.whenOrNull(
          endChatSuccess: () {
            successSnackBar(
              msg: 'common.actionCompletedSuccessfully'.tr(),
              context: context,
            );
            widget.onChatEnded();
          },
          actionError: (messages) {
            failureSnackBar(msg: messages.join('\n'), context: context);
          },
        );
      },
      builder: (context, state) {
        return DesktopCard(
          padding: EdgeInsets.zero,
          child: state.maybeWhen(
            initial: () =>
                const Center(child: CircularProgressIndicator()),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (messages) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(messages.join('\n')),
              ),
            ),
            success: (chatWithMessages, isSending, isEnding) {
              final cubit = context.read<ChatConversationCubit>();
              return Column(
                children: [
                  _ConversationHeader(
                    clientName: widget.chat.client?.name ??
                        'chat.unknownClient'.tr(),
                    avatarUrl: widget.chat.client?.profileImageUrl,
                    isEnded: chatWithMessages.isEnded,
                    canEnd: !chatWithMessages.isEnded && !isEnding,
                    onEndChat: () async {
                      final confirmed =
                          await EndChatConfirmDialog.show(context);
                      if (confirmed == true && context.mounted) {
                        cubit.endChat();
                      }
                    },
                  ),
                  Expanded(
                    child: chatWithMessages.messages.isEmpty
                        ? Center(
                            child: Text(
                              'chat.noMessagesYet'.tr(),
                              style: AppFonts.body(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        : ConversationMessagesList(
                            messages: chatWithMessages.messages,
                            scrollController: _messagesScrollController,
                          ),
                  ),
                  if (!chatWithMessages.isEnded)
                    ConversationInputBar(
                      controller: cubit.messageController,
                      isSending: isSending,
                      onSend: cubit.sendMessage,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.04),
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      child: Text(
                        'chat.endedBanner'.tr(),
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({
    required this.clientName,
    required this.avatarUrl,
    required this.isEnded,
    required this.canEnd,
    required this.onEndChat,
  });

  final String clientName;
  final String? avatarUrl;
  final bool isEnded;
  final bool canEnd;
  final VoidCallback onEndChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          ChatAvatar(imageUrl: avatarUrl, name: clientName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnded
                      ? 'chat.statusEnded'.tr()
                      : 'chat.statusActive'.tr(),
                  style: AppFonts.body(
                    fontSize: 11,
                    color: isEnded
                        ? Colors.grey
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (!isEnded)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(
                  color: theme.colorScheme.error.withValues(alpha: 0.4),
                ),
              ),
              onPressed: canEnd ? onEndChat : null,
              icon: const Icon(Icons.close_rounded, size: 14),
              label: Text('chat.endChat'.tr()),
            ),
        ],
      ),
    );
  }
}

// ─── Contact details pane ──────────────────────────────────────────────────

class _ContactDetailsPane extends StatelessWidget {
  const _ContactDetailsPane({required this.chat});
  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = chat.client;
    return DesktopCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ChatAvatar(
                imageUrl: client?.profileImageUrl,
                name: client?.name ?? '?',
                size: 80,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                client?.name ?? 'chat.unknownClient'.tr(),
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (client?.phone != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  client!.phone!,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
            const Divider(height: 28),
            _DetailRow(
              label: 'chat.statusActive'.tr(),
              value: chat.isEnded
                  ? 'chat.statusEnded'.tr()
                  : 'chat.statusActive'.tr(),
            ),
            if (chat.rating != null && chat.rating! > 0) ...[
              const SizedBox(height: 12),
              Text(
                'chat.rating'.tr(),
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 4),
              ChatRatingStars(rating: chat.rating),
            ],
            if (chat.note != null && chat.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'chat.note'.tr(),
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chat.note!,
                  style: AppFonts.body(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectAPrompt extends StatelessWidget {
  const _SelectAPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'chat.selectToOpen'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
