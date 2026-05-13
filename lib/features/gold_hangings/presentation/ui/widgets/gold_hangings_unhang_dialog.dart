import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class GoldHangingsUnhangDialog {
  static Future<bool> show(BuildContext context, String itemName) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkThemeContainerColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'gold_hangings.unhangConfirmTitle'.tr(),
          style: AppFonts.heading(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkBrown,
          ),
        ),
        content: Text(
          'gold_hangings.unhangConfirmBody'.tr(args: [itemName]),
          style: AppFonts.body(
            fontSize: 13.sp,
            height: 1.5,
            color: isDark
                ? AppColors.textGreyColor
                : AppColors.darkGreyTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'common.cancel'.tr(),
              style: AppFonts.body(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'gold_hangings.unhang'.tr(),
              style: AppFonts.body(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
