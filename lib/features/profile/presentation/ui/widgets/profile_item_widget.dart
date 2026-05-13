import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ProfileItem extends StatelessWidget {
  /// The SVG asset path for the leading icon.
  final String svgPath;

  /// The label shown next to the icon.
  final String title;

  /// Optional subtitle displayed below the title in a lighter style.
  final String? subtitle;

  /// The background tint color applied to the icon container.
 // final Color iconColor;

  /// Called when the item is tapped.
  final VoidCallback onTap;

  /// When true, renders the icon and title in a danger (red) style.
  /// Used for destructive actions like Logout and Delete Account.
  final bool isDanger;

  /// Optional widget rendered on the far right instead of the default chevron.
  final Widget? trailing;

  /// Whether to show the divider line below this item.
  final bool showDivider;

  const ProfileItem({
    super.key,
    required this.svgPath,
    required this.title,
    this.subtitle,
     //this.iconColor,
    required this.onTap,
    this.isDanger = false,
    this.trailing,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

   // final resolvedIconColor = isDanger ? AppColors.errorColor : iconColor;
    final resolvedTitleColor = isDanger
        ? AppColors.errorColor
        : (isDark ? AppColors.lightTextColorForDarkMood : const Color(0xFF2C2C2C));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(0),
          //splashColor: resolvedIconColor.withOpacity(0.06),
        //  highlightColor: resolvedIconColor.withOpacity(0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // ── Icon container ─────────────────────────────────────
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    // color: resolvedIconColor
                    //     .withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      svgPath,
                      width: 20.sp,
                      height: 20.sp,
                      // colorFilter: ColorFilter.mode(
                      //   resolvedIconColor,
                      //   BlendMode.srcIn,
                      // ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // ── Title + optional subtitle ──────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppFonts.body(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: resolvedTitleColor,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: AppFonts.body(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.textGreyColor
                                : AppColors.darkGreyTextColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Trailing ────────────────────────────────────────────
                trailing ??
                    SvgPicture.asset(
                      Assets.assetsImagesProfileChevronRightIcon,
                      width: 16.sp,
                      height: 16.sp,
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor.withOpacity(0.4),
                        BlendMode.srcIn,
                      ),
                    ),
              ],
            ),
          ),
        ),

        // ── Divider ─────────────────────────────────────────────────────
        if (showDivider)
          Divider(
            height: 1,
            indent: 70.w,
            endIndent: 16.w,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.primaryColor.withOpacity(0.12),
          ),
      ],
    );
  }
}
