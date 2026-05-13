import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_unified_sell_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_history_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_history_state.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_history_card.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_history_detail_modal.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_history_shimmer.dart';

class DiamondSellHistoryBlocBuilder extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onAddNew;

  const DiamondSellHistoryBlocBuilder({
    super.key,
    required this.onRetry,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiamondSellHistoryCubit, DiamondSellHistoryState>(
      builder: (context, state) => switch (state) {
        DiamondSellHistoryInitial() ||
        DiamondSellHistoryLoading() =>
          const DiamondSellHistoryShimmer(),
        DiamondSellHistorySuccess(:final sells) =>
          _SuccessView(sells: sells, onAddNew: onAddNew),
        DiamondSellHistoryError(:final message) =>
          _ErrorView(message: message, onRetry: onRetry),
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  final List<DiamondUnifiedSellHistoryModel> sells;
  final VoidCallback onAddNew;

  const _SuccessView({required this.sells, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sells.isEmpty) {
      const accentColor = Color(0xFF64B5F6);
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond_outlined,
                size: 52.sp,
                color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'common.noSellsYet'.tr(),
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
                'Tap the button below to create your first diamond & stone sell.',
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13.sp,
                  color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddNew,
                  icon: Icon(Icons.add_rounded, size: 18.sp),
                  label: Text(
                    'Add New Order',
                    style: AppFonts.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
      itemCount: sells.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => DiamondSellHistoryDetailModal.show(context, sells[index]),
        child: DiamondSellHistoryCard(sell: sells[index]),
      ),
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
              Icon(Icons.error_outline_rounded,
                  color: AppColors.errorColor, size: 34.sp),
              SizedBox(height: 12.h),
              Text(
                'Unable to load history',
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
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
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
                        borderRadius: BorderRadius.circular(12.r)),
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
