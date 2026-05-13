import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/config/branch_model.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:kenooz_worker_app/features/delete_account/presentation/cubit/delete_account_cubit.dart';
import 'package:kenooz_worker_app/features/logout/presentation/cubit/logout_cubit.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/widgets/profile_item_widget.dart';

class ProfileInfoWidget extends StatelessWidget {
  final ProfileResponseModel profile;
  const ProfileInfoWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // ── Contact Information ─────────────────────────────────────
          _SectionTitle(title: 'profile_worker.contactInfo'.tr(), isDark: isDark),
          SizedBox(height: 12.h),
          _InfoCard(
            isDark: isDark,
            children: [
              _InfoRow(
                svgPath: Assets.assetsImagesProfileEmailIcon,
               // iconColor: AppColors.goldColor,
                label: 'profile_worker.email'.tr(),
                value: profile.email,
                isDark: isDark,
              ),
              _InfoDivider(isDark: isDark),
              _InfoRow(
                svgPath: Assets.assetsImagesProfilePhoneIcon,
               // iconColor: AppColors.successColor,
                label: 'profile_worker.phone'.tr(),
                value: profile.phone,
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── General Menu ────────────────────────────────────────────
          _SectionTitle(title: 'profile_worker.general'.tr(), isDark: isDark),
          SizedBox(height: 12.h),
          _MenuCard(
            isDark: isDark,
            children: [
              // ProfileItem(
              //   svgPath: Assets.assetsImagesEditProfileIcon,
              //   title: 'profile_worker.editProfile'.tr(),
              //   //iconColor: AppColors.goldColor,
              //   onTap: () => context.pushNamed(
              //     Routes.editProfileScreen,
              //     arguments: profile,
              //   ),
              //   showDivider: true,
              // ),
              // ProfileItem(
              //   svgPath: Assets.assetsImagesProfileOrdersIcon,
              //   title: 'profile_worker.orders'.tr(),
              //   //iconColor: AppColors.darkBrown,
              //   onTap: () => context.pushNamed(Routes.ordersScreen),
              //   showDivider: true,
              // ),
              ProfileItem(
                svgPath: Assets.assetsImagesLanguageIcon,
                title: 'profile_worker.languageAndRegion'.tr(),
                //iconColor: const Color(0xFF5B8DEF),
                onTap: () => _showLanguageSwitcher(context, isDark),
                showDivider: true,
              ),
              ProfileItem(
                svgPath: Assets.assetsImagesSettingIcon,
                title: 'settings.entryTitle'.tr(),
                subtitle: 'settings.entrySubtitle'.tr(),
                onTap: () => context.pushNamed(Routes.settingsScreen),
                showDivider: true,
              ),
              ProfileItem(
                svgPath: Assets.assetsImagesSettingIcon,
                title: 'branch.switchBranch'.tr(),
                subtitle: _currentBranchName,
                onTap: () => _showBranchSwitchDialog(context, isDark),
                showDivider: false,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Danger Zone ─────────────────────────────────────────────
          _MenuCard(
            isDark: isDark,
            children: [
              ProfileItem(
                svgPath: Assets.assetsImagesLogoutIcon,
                title: 'profile_worker.logout'.tr(),
                //iconColor: AppColors.errorColor,
                isDanger: true,
                onTap: () => _showLogoutDialog(context, isDark),
                showDivider: true,
              ),
              ProfileItem(
                svgPath: Assets.assetsImagesDeleteIcon,
                title: 'profile_worker.deleteAccount'.tr(),
                //  iconColor: AppColors.errorColor,
                isDanger: true,
                onTap: () => _showDeleteAccountDialog(context, isDark),
                showDivider: false,
              ),
            ],
          ),

          SizedBox(height: 36.h),
        ],
      ),
    );
  }

  // ── Current branch name helper ─────────────────────────────────────────────
  String get _currentBranchName {
    final BranchModel? branch = CacheHelper.getSavedBranch();
    return branch?.name ?? '';
  }

  // ── Branch switch confirmation dialog ─────────────────────────────────────
  void _showBranchSwitchDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        isDark: isDark,
        title: 'branch.switchBranch'.tr(),
        message: 'branch.switchConfirm'.tr(),
        confirmLabel: 'branch.switchButton'.tr(),
        isDanger: false,
        onConfirm: () async {
          Navigator.of(context).pop(); // close dialog

          // 1. Clear branch + auth data
          await CacheHelper.clearBranch();
          await CacheHelper.clearAuthDataPreservingBiometric();
          TokenManager().cancelTimer();

          // 2. Reset services to default
          await resetServicesForBranch(
            (CacheHelper.getSavedBranch())?.baseUrl ?? 'https://system.kenooz.co/api/',
          );

          if (!context.mounted) return;

          // 3. Navigate to branch selection
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.branchSelectionScreen,
            (_) => false,
          );
        },
      ),
    );
  }

  // ── Logout confirmation dialog ─────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        isDark: isDark,
        title: 'profile_worker.logout'.tr(),
        message: 'profile_worker.logoutConfirm'.tr(),
        confirmLabel: 'profile_worker.logout'.tr(),
        isDanger: true,
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<LogoutCubit>().emitLogoutStates();
        },
      ),
    );
  }

  // ── Delete account confirmation dialog ────────────────────────────────────
  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        isDark: isDark,
        title: 'profile_worker.deleteAccount'.tr(),
        message: 'profile_worker.deleteAccountConfirm'.tr(),
        confirmLabel: 'profile_worker.delete'.tr(),
        isDanger: true,
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<DeleteAccountCubit>().emitDeleteAccountStates();
        },
      ),
    );
  }

  // ── Language switcher bottom sheet ─────────────────────────────────────────
  void _showLanguageSwitcher(BuildContext context, bool isDark) {
    final isCurrentlyArabic = !CacheHelper.isEnglish();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 18.h),

            // Title
            Text(
              'profile_worker.chooseLanguage'.tr(),
              style: AppFonts.heading(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
            SizedBox(height: 20.h),

            // English option
            _LanguageOption(
              isDark: isDark,
              label: 'English',
              subtitle: 'English',
              isSelected: !isCurrentlyArabic,
              onTap: () {
                Navigator.pop(context);
                if (isCurrentlyArabic) {
                  context.read<SettingsCubit>().changeLanguage(
                    context: context,
                    lang: 'en',
                    country: 'UK',
                  );
                }
              },
            ),
            SizedBox(height: 10.h),

            // Arabic option
            _LanguageOption(
              isDark: isDark,
              label: 'العربية',
              subtitle: 'Arabic',
              isSelected: isCurrentlyArabic,
              onTap: () {
                Navigator.pop(context);
                if (!isCurrentlyArabic) {
                  context.read<SettingsCubit>().changeLanguage(
                    context: context,
                    lang: 'ar',
                    country: 'EG',
                  );
                }
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFonts.heading(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.lightTextColorForDarkMood
            : AppColors.darkGreyTextColor,
      ),
    );
  }
}

// ── Info Card (read-only) ────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _InfoCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.primaryColor.withOpacity(0.12),
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
      child: Column(children: children),
    );
  }
}

// ── Menu Card (tappable items) ───────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _MenuCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.primaryColor.withOpacity(0.12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(children: children),
      ),
    );
  }
}

// ── Info Row (non-tappable) ──────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String svgPath;
 // final Color iconColor;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.svgPath,
    //required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
             // color: iconColor.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 20.sp,
                height: 20.sp,
               // colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: AppFonts.body(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : const Color(0xFF2C2C2C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Divider ─────────────────────────────────────────────────────────────────

class _InfoDivider extends StatelessWidget {
  final bool isDark;
  const _InfoDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70.w,
      endIndent: 16.w,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : AppColors.primaryColor.withOpacity(0.12),
    );
  }
}

// ── Confirm Dialog ───────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final bool isDark;
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.isDark,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDanger,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDanger ? AppColors.errorColor : AppColors.darkBrown;

    return Dialog(
      backgroundColor:
          isDark ? AppColors.darkThemeContainerColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  isDanger
                      ? Assets.assetsImagesDeleteIcon
                      : Assets.assetsImagesSettingIcon,
                  width: 24.sp,
                  height: 24.sp,
                 // colorFilter: ColorFilter.mode(confirmColor, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              title,
              style: AppFonts.heading(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkGreyTextColor,
              ),
            ),
            SizedBox(height: 8.h),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                fontSize: 13.sp,
                color: AppColors.textGreyColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.primaryColor.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'profile_worker.cancel'.tr(),
                      style: AppFonts.body(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppFonts.body(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language Option ─────────────────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  final bool isDark;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.isDark,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.goldColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withOpacity(isDark ? 0.12 : 0.06)
                : (isDark
                    ? Colors.white.withOpacity(0.04)
                    : AppColors.backGroundColorLight),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? selectedColor.withOpacity(0.5)
                  : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.darkBrown.withOpacity(0.1)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFonts.heading(
                        fontSize: 16.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? selectedColor
                            : (isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.darkBrown),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppFonts.body(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: selectedColor,
                  size: 24.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
