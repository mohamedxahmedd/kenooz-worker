import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_create_carat_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_history_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_preload_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_sell_link_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_submit_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui_desktop/gold_buy_desktop_screen.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_history_bloc_builder.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_cubit.dart';

class GoldBuyHistoryScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const GoldBuyHistoryScreen({super.key, this.onMenuTap});

  @override
  State<GoldBuyHistoryScreen> createState() => _GoldBuyHistoryScreenState();
}

class _GoldBuyHistoryScreenState extends State<GoldBuyHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoldBuyHistoryCubit>().fetchHistory();
  }

  void _openNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => GoldBuyPreloadCubit(getIt())),
            BlocProvider(create: (_) => GoldBuyClientSearchCubit(getIt())),
            BlocProvider(create: (_) => GoldBuySellLinkCubit(getIt())),
            BlocProvider(create: (_) => GoldBuyCreateCaratCubit(getIt())),
            BlocProvider(create: (_) => GoldBuySubmitCubit(getIt())),
            BlocProvider(create: (_) => CreateVendorCubit(getIt())),
          ],
          child: const GoldBuyDesktopScreen(),
        ),
      ),
    ).then((_) {
      if (mounted) context.read<GoldBuyHistoryCubit>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkThemeBackgroundColor
          : AppColors.backGroundColorLight,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              MediaQuery.paddingOf(context).top + 12.h,
              20.w,
              10.h,
            ),
            child: _HeaderCard(
              isDark: isDark,
              onMenuTap: widget.onMenuTap,
              onAddNew: _openNewOrder,
            ),
          ),
          Expanded(
            child: GoldBuyHistoryBlocBuilder(
              onRetry: () => context.read<GoldBuyHistoryCubit>().fetchHistory(),
              onAddNew: _openNewOrder,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onMenuTap;
  final VoidCallback onAddNew;

  const _HeaderCard({
    required this.isDark,
    this.onMenuTap,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onMenuTap ?? () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.darkBrown.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.darkBrown.withOpacity(0.1),
                ),
              ),
              child: Icon(
                onMenuTap != null
                    ? Icons.menu_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
                size: 22.sp,
              ),
            ),
          ),
         SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'gold_buy.history'.tr(),
                  style: AppFonts.heading(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                Text(
                  'gold_buy.historySubtitle'.tr(),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onAddNew,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.goldColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'common.addNew'.tr(),
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
