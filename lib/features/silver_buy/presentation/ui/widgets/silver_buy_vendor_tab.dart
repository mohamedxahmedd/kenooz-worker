import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_vendor_model.dart';

class SilverBuyVendorTab extends StatelessWidget {
  final List<SilverVendorModel> vendors;
  final SilverVendorModel? selectedVendor;
  final ValueChanged<SilverVendorModel?> onChanged;
  final VoidCallback onOpenCreateVendorSheet;

  const SilverBuyVendorTab({
    super.key,
    required this.vendors,
    required this.selectedVendor,
    required this.onChanged,
    required this.onOpenCreateVendorSheet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.silverColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'common.vendor'.tr(),
                style: AppFonts.heading(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.silverColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onOpenCreateVendorSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.silverColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.silverColor.withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 15.sp,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.silverColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'common.addVendor'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.silverColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<SilverVendorModel>(
            value: selectedVendor,
            decoration: _inputDecoration('common.chooseVendor'.tr(), isDark),
            dropdownColor: isDark
                ? AppColors.darkThemeContainerColorElevated
                : Colors.white,
            iconEnabledColor: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.silverColor,
            items: vendors
                .map(
                  (vendor) => DropdownMenuItem<SilverVendorModel>(
                    value: vendor,
                    child: Text(vendor.name),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.silverColor.withOpacity(0.16),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.silverColor),
      ),
    );
  }
}
