import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';

class DoubleSellWorkerSelector extends StatelessWidget {
  final List<ShopWorkerModel> workers;
  final ShopWorkerModel? selectedWorker;
  final ValueChanged<ShopWorkerModel?> onChanged;

  const DoubleSellWorkerSelector({
    super.key,
    required this.workers,
    required this.selectedWorker,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'common.worker'.tr(),
            style: AppFonts.heading(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<ShopWorkerModel>(
            value: selectedWorker,
            decoration: _inputDecoration(isDark),
            dropdownColor:
                isDark ? AppColors.darkThemeContainerColorElevated : Colors.white,
            iconEnabledColor:
                isDark ? AppColors.lightTextColorForDarkMood : AppColors.darkBrown,
            style: AppFonts.body(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkGreyTextColor,
            ),
            items: workers
                .map(
                  (worker) => DropdownMenuItem<ShopWorkerModel>(
                    value: worker,
                    child: Text(worker.name),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.darkBrown),
      ),
    );
  }
}
