import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';

class DoubleSellSummaryWidget extends StatelessWidget {
  final double sellTotal;
  final double buyTotal;
  final double net;
  final double finalTotal;
  final TextEditingController taxController;
  final ValueChanged<String> onTaxChanged;

  const DoubleSellSummaryWidget({
    super.key,
    required this.sellTotal,
    required this.buyTotal,
    required this.net,
    required this.finalTotal,
    required this.taxController,
    required this.onTaxChanged,
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
          _line(context, 'gold_double_sell.sellTotal'.tr(), sellTotal),
          _line(context, 'gold_double_sell.buyTotal'.tr(), buyTotal),
          _line(context, 'gold_double_sell.net'.tr(), net),
          SizedBox(height: 8.h),
          CustomTextFormField(
            controller: taxController,
            labelText: 'gold_double_sell.taxPercent'.tr(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onTaxChanged,
            height: 68.h,
            borderRadius: BorderRadius.circular(12.r),
            borderColor: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.darkBrown.withOpacity(0.1),
            fillColor: isDark
                ? Colors.white.withOpacity(0.04)
                : AppColors.backGroundColorLight,
          ),
          SizedBox(height: 6.h),
          _line(context, 'gold_double_sell.finalTotal'.tr(), finalTotal, emphasized: true),
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
