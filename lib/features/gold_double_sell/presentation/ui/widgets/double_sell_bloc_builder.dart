import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_preload_data.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_shimmer.dart';

class DoubleSellBlocBuilder extends StatelessWidget {
  final Widget Function(DoubleSellPreloadData data) successBuilder;
  final VoidCallback onRetry;

  const DoubleSellBlocBuilder({
    super.key,
    required this.successBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoubleSellPreloadCubit, DoubleSellPreloadState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const DoubleSellShimmer(),
          success: successBuilder,
          error: (messages) => _ErrorView(
            message: messages.join('\n'),
            onRetry: onRetry,
          ),
          orElse: () => const DoubleSellShimmer(),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.errorColor.withOpacity(0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.errorColor,
                size: 34.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'common.unableToLoadData'.tr(),
                style: AppFonts.heading(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkBrown,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13.sp,
                  color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('common.retry'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
