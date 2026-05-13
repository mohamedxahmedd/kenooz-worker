import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';



class InfoDisclaimerBox extends StatelessWidget {
  const InfoDisclaimerBox({
    super.key,
    required this.message,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
  });

  final String message;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? AppColors.primaryColor.withOpacity(0.15)
                : AppColors.secondryColor),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : AppColors.primaryColor.withOpacity(0.2)),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: iconColor ??
                (isDark
                    ? AppColors.primaryColor.withOpacity(0.9)
                    : AppColors.primaryColor),
            size: 20.sp,
          ),
          horizontalSpace(10),
          Expanded(
            child: Text(
              message,
              style: TextStyles.textStyle13.copyWith(
                color: textColor ??
                    (isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.homeHeadersLightThemeColor),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
