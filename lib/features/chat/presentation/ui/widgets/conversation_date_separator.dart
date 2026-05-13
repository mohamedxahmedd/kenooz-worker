import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ConversationDateSeparator extends StatelessWidget {
  final DateTime date;

  const ConversationDateSeparator({super.key, required this.date});

  String _label(BuildContext context) {
    final now = DateTime.now();
    final isToday = now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
    if (isToday) return 'chat.today'.tr();

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
    if (isYesterday) return 'chat.yesterday'.tr();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkThemeContainerColor
                : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.primaryColor.withOpacity(0.18),
            ),
          ),
          child: Text(
            _label(context),
            style: AppFonts.body(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textGreyColor,
            ),
          ),
        ),
      ),
    );
  }
}
