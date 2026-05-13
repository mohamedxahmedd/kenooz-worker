import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/chat/data/models/chat_with_messages_model.dart';
import 'chat_rating_stars.dart';

class ConversationEndedBanner extends StatelessWidget {
  final ChatWithMessagesModel chat;

  const ConversationEndedBanner({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasRating = chat.rating != null && chat.rating! > 0;
    final hasNote = chat.note != null && chat.note!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        16.w,
        14.h + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkThemeContainerColor
            : AppColors.backGroundColorLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.primaryColor.withOpacity(0.18),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.errorColor,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'chat.endedBanner'.tr(),
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkGreyTextColor,
                  ),
                ),
              ),
            ],
          ),
          if (hasRating) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  '${'chat.rating'.tr()}: ',
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    color: AppColors.textGreyColor,
                  ),
                ),
                ChatRatingStars(rating: chat.rating, size: 16),
              ],
            ),
          ],
          if (hasNote) ...[
            SizedBox(height: 8.h),
            Text(
              '${'chat.note'.tr()}: ${chat.note}',
              style: AppFonts.body(
                fontSize: 12.sp,
                color: AppColors.textGreyColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
