import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:intl/intl.dart';

class HomeHeaderWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onMenuTap;
  const HomeHeaderWidget({super.key, required this.onRefresh, this.onMenuTap});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home_worker.goodMorning'.tr();
    if (hour < 17) return 'home_worker.goodAfternoon'.tr();
    return 'home_worker.goodEvening'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName =
        (CacheHelper.getData(key: CacheKeys.userName) as String?)?.trim() ??
        'common.worker'.tr();
    final displayName = userName.isEmpty ? 'common.worker'.tr() : userName;
    final today = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
    final topInset = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, topInset + 12.h, 20.w, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.primaryColor.withOpacity(0.14),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.darkBrown.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap:
                      onMenuTap ??
                      () => Scaffold.maybeOf(context)?.openDrawer(),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : AppColors.darkBrown.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 22.sp,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.darkBrown,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home_worker.home'.tr(),
                        style: AppFonts.heading(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$_greeting, $displayName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor.withOpacity(0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onRefresh,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkThemeContainerColorElevated
                          : AppColors.darkBrown.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : AppColors.darkBrown.withOpacity(0.12),
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20.sp,
                      color: isDark
                          ? AppColors.lightTextColorForDarkMood
                          : AppColors.darkBrown,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _InfoChip(
                  isDark: isDark,
                  icon: Icons.calendar_today_outlined,
                  label: today,
                ),
                _InfoChip(
                  isDark: isDark,
                  icon: Icons.analytics_outlined,
                  label: 'home_worker.liveRates'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.darkBrown.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkBrown,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}
