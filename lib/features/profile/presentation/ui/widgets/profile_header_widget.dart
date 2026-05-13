import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileResponseModel profile;
  final VoidCallback? onMenuTap;
  const ProfileHeaderWidget({super.key, required this.profile, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final cleanName = profile.name.replaceAll(r'\', '').trim();
    final displayName = cleanName.isEmpty ? 'profile_worker.workerProfile'.tr() : cleanName;
    final contactText = profile.email.trim().isNotEmpty
        ? profile.email
        : profile.phone;
    final roleLabel = profile.role.trim().isEmpty ? 'profile_worker.worker'.tr() : profile.role;
    final isOnline = profile.isOnline == 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  onTap: onMenuTap ?? () => Scaffold.maybeOf(context)?.openDrawer(),
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
                _ProfileAvatar(
                  initial: displayName[0].toUpperCase(),
                  isOnline: isOnline,
                  isDark: isDark,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.heading(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        contactText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor.withOpacity(0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _RoleChip(role: roleLabel, isDark: isDark),
                _StatusChip(isOnline: isOnline, isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Avatar ──────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String initial;
  final bool isOnline;
  final bool isDark;

  const _ProfileAvatar({
    required this.initial,
    required this.isOnline,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      height: 72.w,
      child: Stack(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkThemeContainerColorElevated
                  : AppColors.darkBrown.withOpacity(0.06),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.darkBrown.withOpacity(0.14),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: AppFonts.heading(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkBrown,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 1.r,
            right: 1.r,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? AppColors.successColor
                    : AppColors.textGreyColor,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkThemeContainerColor
                      : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Chip ────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String role;
  final bool isDark;

  const _RoleChip({required this.role, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
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
          SvgPicture.asset(
            Assets.assetsImagesProfileRoleIcon,
            width: 14.sp,
            height: 14.sp,
            colorFilter: ColorFilter.mode(
              isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            role.toUpperCase(),
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool isOnline;
  final bool isDark;
  const _StatusChip({required this.isOnline, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline
        ? AppColors.successColor
        : (isDark
              ? AppColors.textGreyColor
              : AppColors.darkGreyTextColor.withOpacity(0.65));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
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
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            isOnline ? 'profile_worker.online'.tr() : 'profile_worker.offline'.tr(),
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkGreyTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
