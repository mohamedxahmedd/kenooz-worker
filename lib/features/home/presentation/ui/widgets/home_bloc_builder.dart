import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/home/data/models/home_data_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/update_price_response_model.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/home_state.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_cubit.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_state.dart'
    as update_rates;
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_state.dart'
    show UpdateRatesState;
import 'package:kenooz_worker_app/features/home/presentation/ui/widgets/home_gold_rate_widget.dart';
import 'package:kenooz_worker_app/features/home/presentation/ui/widgets/home_header_widget.dart';
import 'package:kenooz_worker_app/features/home/presentation/ui/widgets/home_silver_rate_widget.dart';
import 'package:kenooz_worker_app/features/home/presentation/ui/widgets/home_usd_rate_widget.dart';
import 'package:shimmer/shimmer.dart';

class HomeBlocBuilder extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const HomeBlocBuilder({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateRatesCubit, UpdateRatesState>(
      listenWhen: (previous, current) =>
          current is update_rates.Loading ||
          current is update_rates.Success ||
          current is update_rates.Error,
      listener: (context, state) {
        switch (state) {
          case update_rates.Loading():
            EasyLoading.show();
          case update_rates.Success(:final data):
            EasyLoading.dismiss();
            final response = data as UpdatePriceResponseModel?;
            successSnackBar(
              msg: response?.message ?? 'common.rateUpdatedSuccessfully'.tr(),
              context: context,
            );
            context.read<HomeCubit>().fetchAllRates();
          case update_rates.Error(:final messages):
            EasyLoading.dismiss();
            failureSnackBar(msg: messages.first, context: context);
          case update_rates.Initial():
            break;
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          Loading() => const _ShimmerLoadingView(),
          Success(:final data) => _SuccessView(
              homeData: data as HomeDataModel,
              onMenuTap: onMenuTap,
            ),
          Error(:final messages) => _ErrorView(
              message: messages.first,
              onRetry: () => context.read<HomeCubit>().fetchAllRates(),
              onMenuTap: onMenuTap,
            ),
          Initial() => const SizedBox.shrink(),
        },
      ),
    );
  }
}

// ── Shimmer Loading ──────────────────────────────────────────────────────────

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
    final topInset = MediaQuery.paddingOf(context).top;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, topInset + 12.h, 20.w, 0),
              child: _ShimmerBox(
                width: double.infinity,
                height: 118.h,
                radius: 18.r,
              ),
            ),
            SizedBox(height: 18.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _ShimmerBox(
                    width: double.infinity,
                    height: 74.h,
                    radius: 16.r,
                  ),
                  SizedBox(height: 16.h),
                  _ShimmerBox(
                    width: double.infinity,
                    height: 88.h,
                    radius: 18.r,
                  ),
                  SizedBox(height: 16.h),

                  // Gold shimmer
                  _ShimmerBox(
                    width: double.infinity,
                    height: 210.h,
                    radius: 18.r,
                  ),
                  SizedBox(height: 16.h),

                  _ShimmerBox(
                    width: double.infinity,
                    height: 190.h,
                    radius: 18.r,
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

// ── Success View ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final HomeDataModel homeData;
  final VoidCallback? onMenuTap;

  const _SuccessView({required this.homeData, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.darkBrown,
      backgroundColor: isDark
          ? AppColors.darkThemeContainerColor
          : Colors.white,
      onRefresh: () async => context.read<HomeCubit>().fetchAllRates(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeaderWidget(
              onRefresh: () => context.read<HomeCubit>().fetchAllRates(),
              onMenuTap: onMenuTap,
            ),

            SizedBox(height: 10.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                //  _RatesSnapshotCard(homeData: homeData, isDark: isDark),
                  SizedBox(height: 10.h),

                  _SectionLabel(
                    label: 'Current Rates'.tr(),
                    isDark: isDark,
                    badge: 'home_worker.usd'.tr(),
                  ),
                  SizedBox(height: 14.h),

                  HomeUsdRateWidget(
                    usdRate: homeData.usdRate.usd,
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),

                  _SectionLabel(
                    label: 'Gold Prices'.tr(),
                    isDark: isDark,
                    badge: '21K Base'.tr(),
                  ),
                  SizedBox(height: 14.h),
                  HomeGoldRateWidget(
                    goldRates: homeData.goldRates,
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),

                  _SectionLabel(
                    label: 'Silver Prices'.tr(),
                    isDark: isDark,
                    badge: 'Base 999'.tr(),
                  ),
                  SizedBox(height: 14.h),
                  HomeSilverRateWidget(
                    silverRates: homeData.silverRates,
                    isDark: isDark,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  final String? badge;

  const _SectionLabel({required this.label, required this.isDark, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppFonts.heading(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkGreyTextColor,
          ),
        ),
        const Spacer(),
        if (badge != null)
          Container(
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
            child: Text(
              badge!,
              style: AppFonts.body(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
            ),
          ),
      ],
    );
  }
}

class _RatesSnapshotCard extends StatelessWidget {
  final HomeDataModel homeData;
  final bool isDark;

  const _RatesSnapshotCard({required this.homeData, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gold21 = homeData.goldRates.carats
        .where((carat) => carat.carat.replaceAll(RegExp(r'[^0-9]'), '') == '21')
        .toList();
    final goldPrice = gold21.isNotEmpty
        ? gold21.first.price.toStringAsFixed(2)
        : '--';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
      child: Row(
        children: [
          Expanded(
            child: _SnapshotItem(
              title: 'home_worker.usd'.tr(),
              value: homeData.usdRate.usd.toStringAsFixed(2),
              suffix: 'EGP',
              isDark: isDark,
            ),
          ),
          _SnapshotDivider(isDark: isDark),
          Expanded(
            child: _SnapshotItem(
              title: 'home_worker.gold21K'.tr(),
              value: goldPrice,
              suffix: 'EGP',
              isDark: isDark,
            ),
          ),
          _SnapshotDivider(isDark: isDark),
          Expanded(
            child: _SnapshotItem(
              title: 'home_worker.silver'.tr(),
              value: homeData.silverRates.carats.length.toString(),
              suffix: 'Carats',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotDivider extends StatelessWidget {
  final bool isDark;

  const _SnapshotDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : AppColors.primaryColor.withOpacity(0.16),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final bool isDark;

  const _SnapshotItem({
    required this.title,
    required this.value,
    required this.suffix,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.body(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textGreyColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.heading(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkGreyTextColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          suffix,
          style: AppFonts.body(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textGreyColor,
          ),
        ),
      ],
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onMenuTap;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Keep header visible even on error
        HomeHeaderWidget(onRefresh: onRetry, onMenuTap: onMenuTap),

        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkThemeContainerColor
                      : Colors.white,
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
          ),
        ),
      ],
    );
  }
}
