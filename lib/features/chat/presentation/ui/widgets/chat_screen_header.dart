import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ChatScreenHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const ChatScreenHeader({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
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
        children: [
          InkWell(
            onTap: onMenuTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : AppColors.darkBrown.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.menu_rounded,
                size: 20.sp,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat.title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkGreyTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'chat.subtitle'.tr(),
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor.withOpacity(0.72),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkThemeContainerColorElevated
                  : AppColors.darkBrown.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.darkBrown.withOpacity(0.12),
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 22.sp,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}
