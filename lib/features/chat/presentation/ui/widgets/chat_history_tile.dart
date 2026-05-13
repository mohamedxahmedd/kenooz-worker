import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_model.dart';
import 'chat_avatar.dart';
import 'chat_rating_stars.dart';

class ChatHistoryTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatHistoryTile({super.key, required this.chat, required this.onTap});

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
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
    final lastMessage = chat.latestMessage?.message ?? '';
    final closedDate = _formatDate(chat.updatedAt);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ChatAvatar(
                    imageUrl: chat.client?.profileImageUrl,
                    name: clientName,
                    size: 48,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                        SizedBox(height: 4.h),
                        if (lastMessage.isNotEmpty)
                          Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 12.sp,
                              color: AppColors.textGreyColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (closedDate.isNotEmpty)
                    Text(
                      closedDate,
                      style: AppFonts.body(
                        fontSize: 10.sp,
                        color: AppColors.textGreyColor,
                      ),
                    ),
                ],
              ),
              if (chat.rating != null && chat.rating! > 0) ...[
                SizedBox(height: 10.h),
                Row(
                  children: [
                    ChatRatingStars(rating: chat.rating, size: 14),
                    SizedBox(width: 8.w),
                    if (chat.note != null && chat.note!.trim().isNotEmpty)
                      Expanded(
                        child: Text(
                          chat.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 11.sp,
                            color: AppColors.textGreyColor,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
