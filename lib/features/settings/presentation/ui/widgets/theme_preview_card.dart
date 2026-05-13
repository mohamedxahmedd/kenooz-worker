import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/themes.dart';

class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = tokensOf(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: tokens.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.preview'.tr(),
            style: AppFonts.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: tokens.onSurfaceMuted,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: tokens.buttonBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'settings.previewButton'.tr(),
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: tokens.buttonFg,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: tokens.primary, width: 1),
                ),
                child: Text(
                  'settings.previewChip'.tr(),
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: tokens.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'settings.previewBody'.tr(),
            style: AppFonts.body(
              fontSize: 13.sp,
              color: tokens.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
