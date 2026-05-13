import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/delete_account/presentation/cubit/delete_account_cubit.dart';
import 'package:kenooz_worker_app/features/delete_account/presentation/cubit/delete_account_state.dart';
import 'package:kenooz_worker_app/features/logout/presentation/cubit/logout_cubit.dart';
import 'package:kenooz_worker_app/features/logout/presentation/cubit/logout_state.dart'
    hide Loading, Success, Error;
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/widgets/profile_header_widget.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/widgets/profile_info_widget.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/widgets/profile_stats_widget.dart';

class ProfileBlocBuilder extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const ProfileBlocBuilder({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteAccountCubit, DeleteAccountState>(
      listener: (context, state) {
        switch (state) {
          case DeleteAccountLoading():
            EasyLoading.show();
          case DeleteAccountSuccess():
            EasyLoading.dismiss();
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.loginScreen,
              (route) => false,
            );
          case DeleteAccountError(:final messages):
            EasyLoading.dismiss();
            failureSnackBar(msg: messages.first, context: context);
          case DeleteAccountInitial():
            break;
        }
      },
      child: BlocListener<LogoutCubit, LogoutState>(
        listenWhen: (previous, current) => current.maybeWhen(
          loading: () => true,
          success: (_) => true,
          error: (_) => true,
          orElse: () => false,
        ),
        listener: (context, state) {
          state.maybeWhen(
            loading: () => EasyLoading.show(),
            success: (_) {
              EasyLoading.dismiss();
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.loginScreen,
                (route) => false,
              );
            },
            error: (messages) {
              EasyLoading.dismiss();
              failureSnackBar(msg: messages.first, context: context);
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => switch (state) {
          Loading() => const _ShimmerLoadingView(),
          Success(:final data) => _SuccessView(
              profile: data as ProfileResponseModel,
              onMenuTap: onMenuTap,
            ),
          Error(:final messages) => _ErrorView(
              message: messages.first,
              onRetry: () => context.read<ProfileCubit>().getProfile(),
            ),
          Initial() => const SizedBox.shrink(),
        },
      ),
      ),
    );
  }
}

// ── Shimmer Loading ─────────────────────────────────────────────────────────

class _ShimmerLoadingView extends StatelessWidget {
  const _ShimmerLoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1C2B24)
        : const Color(0xFFE8E8E8);
    final highlightColor = isDark
        ? const Color(0xFF243630)
        : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                MediaQuery.paddingOf(context).top + 12.h,
                20.w,
                0,
              ),
              child: _ShimmerBox(
                width: double.infinity,
                height: 150.h,
                radius: 18.r,
              ),
            ),

            // Stats shimmer
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 150.w, height: 18.h),
                  SizedBox(height: 14.h),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 10.w : 0),
                          child: _ShimmerBox(
                            width: double.infinity,
                            height: 110.h,
                            radius: 16.r,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  _ShimmerBox(width: 140.w, height: 18.h),
                  SizedBox(height: 12.h),
                  _ShimmerBox(
                    width: double.infinity,
                    height: 130.h,
                    radius: 16.r,
                  ),
                  SizedBox(height: 24.h),
                  _ShimmerBox(width: 120.w, height: 18.h),
                  SizedBox(height: 12.h),
                  _ShimmerBox(
                    width: double.infinity,
                    height: 240.h,
                    radius: 16.r,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Success ─────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final ProfileResponseModel profile;
  final VoidCallback? onMenuTap;
  const _SuccessView({required this.profile, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeaderWidget(profile: profile, onMenuTap: onMenuTap),
        //  ProfileStatsWidget(profile: profile),
          ProfileInfoWidget(profile: profile),
        //  verticalSpace(10.h),
        ],
      ),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.errorColor.withOpacity(0.1),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    Assets.assetsImagesProfileErrorIcon,
                    width: 30.sp,
                    height: 30.sp,
                    colorFilter: ColorFilter.mode(
                      AppColors.errorColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'common.somethingWentWrong'.tr(),
                style: AppFonts.heading(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkGreyTextColor,
                ),
              ),
              SizedBox(height: 8.h),

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

              // Retry button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'common.tryAgain'.tr(),
                    style: AppFonts.body(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
