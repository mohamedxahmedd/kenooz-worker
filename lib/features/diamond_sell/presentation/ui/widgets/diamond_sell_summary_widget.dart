import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';

class DiamondSellSummaryWidget extends StatelessWidget {
  final int diamondCount;
  final int stoneCount;
  final double diamondTotal;
  final double stoneTotal;
  final double grandTotal;
  final TextEditingController notesController;

  const DiamondSellSummaryWidget({
    super.key,
    required this.diamondCount,
    required this.stoneCount,
    required this.diamondTotal,
    required this.stoneTotal,
    required this.grandTotal,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          if (diamondCount > 0) _line(context, '${'diamond_sell.diamond'.tr()} ($diamondCount)', diamondTotal),
          if (stoneCount > 0) _line(context, '${'diamond_sell.stone'.tr()} ($stoneCount)', stoneTotal),
          SizedBox(height: 6.h),
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.darkBrown.withOpacity(0.1),
            height: 1,
          ),
          SizedBox(height: 6.h),
          _line(context, 'diamond_sell.grandTotal'.tr(), grandTotal, emphasized: true),
          SizedBox(height: 10.h),
          CustomTextFormField(
            controller: notesController,
            labelText: 'common.notesOptional'.tr(),
            minLines: 2,
            maxLines: 3,
            height: 80.h,
            borderRadius: BorderRadius.circular(12.r),
            borderColor: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.darkBrown.withOpacity(0.1),
            fillColor: isDark
                ? Colors.white.withOpacity(0.04)
                : AppColors.backGroundColorLight,
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    double value, {
    bool emphasized = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: AppFonts.body(
              fontSize: emphasized ? 14.sp : 12.sp,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
          ),
          const Spacer(),
          Text(
            value.toStringAsFixed(2),
            style: AppFonts.body(
              fontSize: emphasized ? 15.sp : 13.sp,
              fontWeight: FontWeight.w700,
              color: emphasized ? AppColors.successColor : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}
