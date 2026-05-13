import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_message_model.dart';
import 'chat_message_bubble.dart';
import 'conversation_date_separator.dart';

class ConversationMessagesList extends StatefulWidget {
  final List<ChatMessageModel> messages;
  final ScrollController scrollController;

  const ConversationMessagesList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  State<ConversationMessagesList> createState() =>
      _ConversationMessagesListState();
}

class _ConversationMessagesListState extends State<ConversationMessagesList> {
  int _previousLength = 0;

  @override
  void initState() {
    super.initState();
    _previousLength = widget.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant ConversationMessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != _previousLength) {
      _previousLength = widget.messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (!widget.scrollController.hasClients) return;
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;

    if (messages.isEmpty) {
      return const SizedBox.expand();
    }

    final items = <Widget>[];
    DateTime? lastDate;

    for (final msg in messages) {
      DateTime? date;
      try {
        date = DateTime.parse(msg.createdAt).toLocal();
      } catch (_) {
        date = null;
      }
      if (date != null && (lastDate == null || !_isSameDay(lastDate, date))) {
        items.add(ConversationDateSeparator(date: date));
        lastDate = date;
      }
      items.add(ChatMessageBubble(message: msg));
    }

    return ListView.builder(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: items.length,
      itemBuilder: (_, index) => items[index],
    );
  }
}
