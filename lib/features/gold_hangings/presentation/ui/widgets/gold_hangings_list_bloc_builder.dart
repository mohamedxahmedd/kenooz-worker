import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanged_gold_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_list_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_list_state.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_unhang_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_unhang_state.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/ui/widgets/gold_hangings_card.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/ui/widgets/gold_hangings_shimmer.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/ui/widgets/gold_hangings_unhang_dialog.dart';

class GoldHangingsListBlocBuilder extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onAddNew;

  const GoldHangingsListBlocBuilder({
    super.key,
    required this.onRetry,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoldHangingsListCubit, GoldHangingsListState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const GoldHangingsShimmer(),
          success: (items) => _SuccessView(items: items, onAddNew: onAddNew),
          error: (message) => _ErrorView(message: message, onRetry: onRetry),
          orElse: () => const GoldHangingsShimmer(),
        );
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  final List<HangedGoldModel> items;
  final VoidCallback onAddNew;

  const _SuccessView({required this.items, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.goldColor,
        onRefresh: () =>
            context.read<GoldHangingsListCubit>().fetchHanged(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 80.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 52.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'gold_hangings.emptyTitle'.tr(),
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
                    'gold_hangings.emptyHint'.tr(),
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
                        'gold_hangings.hangProducts'.tr(),
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
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.goldColor,
      onRefresh: () => context.read<GoldHangingsListCubit>().fetchHanged(),
      child: BlocBuilder<GoldHangingsUnhangCubit, GoldHangingsUnhangState>(
        builder: (context, unhangState) {
          final unhangingId = unhangState.maybeWhen(
            loading: (id) => id,
            orElse: () => null,
          );
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = items[index];
              return GoldHangingsCard(
                item: item,
                isUnhanging: unhangingId == item.id,
                onUnhang: () async {
                  final confirmed = await GoldHangingsUnhangDialog.show(
                    context,
                    item.name,
                  );
                  if (!context.mounted || !confirmed) return;
                  context.read<GoldHangingsUnhangCubit>().unhang(item.id);
                },
              );
            },
          );
        },
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
