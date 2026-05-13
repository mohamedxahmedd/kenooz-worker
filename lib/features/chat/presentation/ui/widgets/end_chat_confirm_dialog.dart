import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class EndChatConfirmDialog extends StatelessWidget {
  const EndChatConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const EndChatConfirmDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor:
          isDark ? AppColors.darkThemeContainerColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text(
        'chat.endChatConfirmTitle'.tr(),
        style: AppFonts.heading(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.lightTextColorForDarkMood
              : AppColors.darkGreyTextColor,
        ),
      ),
      content: Text(
        'chat.endChatConfirmBody'.tr(),
        style: AppFonts.body(
          fontSize: 14.sp,
          color: AppColors.textGreyColor,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'main_layout.cancel'.tr(),
            style: AppFonts.body(
              fontSize: 14.sp,
              color: AppColors.textGreyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'chat.endChat'.tr(),
            style: AppFonts.body(
              fontSize: 14.sp,
              color: AppColors.errorColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
