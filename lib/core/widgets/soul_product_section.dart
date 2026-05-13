import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

/// A titled horizontal product list section reused on the Home screen
/// for both "Featured Products" and "All Products".
class SoulProductSection extends StatelessWidget {
  const SoulProductSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.onSeeAll,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Section header ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppFonts.heading(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.primaryColor,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: AppFonts.heading(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.goldColor.withValues(alpha: 0.85)
                        : AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
        verticalSpace(12.h),

        // ── Horizontal product list ──────────────────────────────────────
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(width: 16.w),
            addAutomaticKeepAlives: false,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
