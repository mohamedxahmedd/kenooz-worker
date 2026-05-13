import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'chat_avatar.dart';

class ConversationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String clientName;
  final String? clientAvatarUrl;
  final bool isEnded;
  final bool canEnd;
  final VoidCallback onBack;
  final VoidCallback onEndChat;

  const ConversationAppBar({
    super.key,
    required this.clientName,
    required this.clientAvatarUrl,
    required this.isEnded,
    required this.canEnd,
    required this.onBack,
    required this.onEndChat,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.primaryColor.withOpacity(0.16),
          ),
        ),
      ),
      child: SizedBox(
        height: 64.h,
        child: Row(
          children: [
            SizedBox(width: 4.w),
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
                size: 22.sp,
              ),
            ),
            ChatAvatar(
              imageUrl: clientAvatarUrl,
              name: clientName,
              size: 40,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _StatusPill(isEnded: isEnded),
                ],
              ),
            ),
            if (canEnd && !isEnded)
              IconButton(
                tooltip: 'chat.endChat'.tr(),
                onPressed: onEndChat,
                icon: Icon(
                  Icons.exit_to_app_rounded,
                  color: AppColors.errorColor,
                  size: 22.sp,
                ),
              ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isEnded;

  const _StatusPill({required this.isEnded});

  @override
  Widget build(BuildContext context) {
    final color = isEnded ? AppColors.errorColor : AppColors.successColor;
    final label =
        isEnded ? 'chat.statusEnded'.tr() : 'chat.statusActive'.tr();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppFonts.body(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
