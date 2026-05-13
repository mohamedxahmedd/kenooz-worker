import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_full_history_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_history_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_history_state.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_history_card.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_history_detail_modal.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_history_shimmer.dart';

class GoldBuyHistoryBlocBuilder extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onAddNew;

  const GoldBuyHistoryBlocBuilder({
    super.key,
    required this.onRetry,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoldBuyHistoryCubit, GoldBuyHistoryState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const GoldBuyHistoryShimmer(),
          success: (buys) => _SuccessView(buys: buys, onAddNew: onAddNew),
          error: (message) => _ErrorView(message: message, onRetry: onRetry),
          orElse: () => const GoldBuyHistoryShimmer(),
        );
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  final List<GoldBuyFullHistoryModel> buys;
  final VoidCallback onAddNew;

  const _SuccessView({required this.buys, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (buys.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 52.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'common.noBuysYet'.tr(),
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
                'gold_buy.tapButtonToRecord'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
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
                    'common.addNewOrder'.tr(),
                    style: AppFonts.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldColor,
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
      itemCount: buys.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => GoldBuyHistoryDetailModal.show(context, buys[index]),
        child: GoldBuyHistoryCard(buy: buys[index]),
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
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.errorColor,
                size: 34.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'common.unableToLoadHistory'.tr(),
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
