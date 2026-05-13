import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';

class ProfileStatsWidget extends StatelessWidget {
  final ProfileResponseModel profile;
  const ProfileStatsWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = profile.noOfSuccessShipments +
        profile.noOfPendingShipments +
        profile.noOfFailedShipments;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Title ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipments Overview',
                style: AppFonts.heading(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkGreyTextColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBrown.withOpacity(0.25)
                      : AppColors.darkBrown.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Total: $total',
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryColor : AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Stat Cards Row ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Delivered',
                  count: profile.noOfSuccessShipments,
                  svgPath: Assets.assetsImagesProfileSuccessShipmentIcon,
                  accentColor: const Color(0xFF2ecc71),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'Pending',
                  count: profile.noOfPendingShipments,
                  svgPath: Assets.assetsImagesProfilePendingShipmentIcon,
                  accentColor: const Color(0xFFf39c12),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'Failed',
                  count: profile.noOfFailedShipments,
                  svgPath: Assets.assetsImagesProfileFailedShipmentIcon,
                  accentColor: const Color(0xFFe74c3c),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final String svgPath;
  final Color accentColor;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.count,
    required this.svgPath,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkThemeContainerColor
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : accentColor.withOpacity(0.15),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.w,
            // decoration: BoxDecoration(
            //   color: accentColor.withOpacity(isDark ? 0.15 : 0.1),
            //   borderRadius: BorderRadius.circular(12.r),
            // ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 20.sp,
                height: 20.sp,
                colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Count
          Text(
            '$count',
            style: AppFonts.body(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),

          // Label
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
