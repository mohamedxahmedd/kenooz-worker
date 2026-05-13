import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';

class GoldBuyVendorTab extends StatelessWidget {
  final List<GoldVendorModel> vendors;
  final GoldVendorModel? selectedVendor;
  final ValueChanged<GoldVendorModel?> onChanged;
  final VoidCallback onOpenCreateVendorSheet;

  const GoldBuyVendorTab({
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
              : AppColors.primaryColor.withOpacity(0.16),
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
                      : AppColors.darkBrown,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onOpenCreateVendorSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.darkBrown.withOpacity(0.20),
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
                            : AppColors.darkBrown,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'common.addVendor'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<GoldVendorModel>(
            value: selectedVendor,
            decoration: _inputDecoration('common.chooseVendor'.tr(), isDark),
            dropdownColor: isDark
                ? AppColors.darkThemeContainerColorElevated
                : Colors.white,
            iconEnabledColor: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkBrown,
            items: vendors
                .map(
                  (vendor) => DropdownMenuItem<GoldVendorModel>(
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
