import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_message_model.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'chat_avatar.dart';
import 'chat_unread_badge.dart';

class ChatInboxTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatInboxTile({super.key, required this.chat, required this.onTap});

  String _formatPreview(BuildContext context, ChatMessageModel? msg) {
    if (msg == null) return '';
    final prefix = msg.isFromWorker ? '${'chat.you'.tr()}: ' : '';
    return '$prefix${msg.message}';
  }

  String _formatTime(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final isToday = now.year == date.year &&
          now.month == date.month &&
          now.day == date.day;
      if (isToday) {
        final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
        final minute = date.minute.toString().padLeft(2, '0');
        final ampm = date.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $ampm';
      }
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientName = (chat.client?.name ?? '').trim().isEmpty
        ? 'chat.unknownClient'.tr()
        : chat.client!.name;
    final preview = _formatPreview(context, chat.latestMessage);
    final time = _formatTime(
      chat.latestMessage?.createdAt ?? chat.updatedAt,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.primaryColor.withOpacity(0.14),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.darkBrown.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ChatAvatar(
                imageUrl: chat.client?.profileImageUrl,
                name: clientName,
                size: 52,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.heading(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.lightTextColorForDarkMood
                                  : AppColors.darkGreyTextColor,
                            ),
                          ),
                        ),
                        if (time.isNotEmpty)
                          Text(
                            time,
                            style: AppFonts.body(
                              fontSize: 10.sp,
                              color: AppColors.textGreyColor,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview.isEmpty
                                ? 'chat.noMessagesYet'.tr()
                                : preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 12.sp,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: chat.unreadCount > 0
                                  ? (isDark
                                      ? AppColors.lightTextColorForDarkMood
                                      : AppColors.darkGreyTextColor)
                                  : AppColors.textGreyColor,
                            ),
                          ),
                        ),
                        if (chat.unreadCount > 0) ...[
                          SizedBox(width: 8.w),
                          ChatUnreadBadge(count: chat.unreadCount),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
