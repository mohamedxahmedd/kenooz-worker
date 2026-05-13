import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class GoldBuySummaryWidget extends StatelessWidget {
  final double totalBuyPrice;
  final double totalPaid;

  const GoldBuySummaryWidget({
    super.key,
    required this.totalBuyPrice,
    required this.totalPaid,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final difference = totalBuyPrice - totalPaid;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'common.summary'.tr(),
            style: AppFonts.heading(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 10.h),
          _line(context, 'gold_buy.totalBuyPrice'.tr(), totalBuyPrice, isDark: isDark),
          _line(context, 'gold_buy.totalPaid'.tr(), totalPaid, isDark: isDark),
          SizedBox(height: 8.h),
          _line(
            context,
            'gold_buy.difference'.tr(),
            difference,
            isDark: isDark,
            emphasize: true,
            isDifferenceZero: difference == 0,
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    double value, {
    required bool isDark,
    bool emphasize = false,
    bool isDifferenceZero = false,
  }) {
    Color valueColor = AppColors.darkBrown;
    if (emphasize) {
      valueColor = isDifferenceZero
          ? AppColors.successColor
          : AppColors.errorColor;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: AppFonts.body(
              fontSize: emphasize ? 14.sp : 12.sp,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(2)} ${'common.egp'.tr()}',
            style: AppFonts.body(
              fontSize: emphasize ? 15.sp : 13.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
