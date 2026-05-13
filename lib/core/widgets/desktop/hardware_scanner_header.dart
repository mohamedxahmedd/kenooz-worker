import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

/// Visible header that frames the product-ID text field as a hardware barcode
/// scanner input. Pairs with a downstream [TextField] / [TextFormField] whose
/// `FocusNode` is passed in here so the live "listening" indicator can react
/// to focus changes — when the field has focus, the badge pulses, signalling
/// that the next scan will be accepted.
class HardwareScannerHeader extends StatelessWidget {
  const HardwareScannerHeader({
    super.key,
    required this.focusNode,
    required this.isDark,
  });

  final FocusNode focusNode;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkThemeContainerColor : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primaryColor.withValues(alpha: 0.14);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.goldColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.goldColor.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.goldColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'common.scannerReady'.tr(),
                  style: AppFonts.heading(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'common.scannerReadyHint'.tr(),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          _ListeningBadge(focusNode: focusNode),
        ],
      ),
    );
  }
}

class _ListeningBadge extends StatelessWidget {
  const _ListeningBadge({required this.focusNode});
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final listening = focusNode.hasFocus;
        final color = listening ? AppColors.goldColor : Colors.grey;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                listening
                    ? 'common.listening'.tr()
                    : 'common.notListening'.tr(),
                style: AppFonts.body(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
