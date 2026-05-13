import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_stats_model.dart';

class OrdersStatsWidget extends StatelessWidget {
  final OrderStatsModel stats;
  final String currentPeriod;
  final Function(String) onPeriodChanged;

  const OrdersStatsWidget({
    super.key,
    required this.stats,
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = stats.entries.entries.toList();

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children: [
        _PeriodSelector(
          isDark: isDark,
          currentPeriod: currentPeriod,
          onPeriodChanged: onPeriodChanged,
        ),
        SizedBox(height: 14.h),
        _StatsSummaryCard(
          isDark: isDark,
          totalOrders: stats.totalCount,
          totalRevenue: stats.totalAmount,
          period: currentPeriod,
        ),
        SizedBox(height: 16.h),
        if (entries.isNotEmpty) ...[
          Text(
            'orders.breakdown'.tr(),
            style: AppFonts.heading(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkGreyTextColor,
            ),
          ),
          SizedBox(height: 10.h),
          ...entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _StatsEntryCard(
                isDark: isDark,
                label: entry.key,
                orders: entry.value.count,
                amount: entry.value.total,
              ),
            ),
          ),
        ] else
          _NoStatsBreakdownCard(isDark: isDark),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final bool isDark;
  final String currentPeriod;
  final Function(String) onPeriodChanged;

  const _PeriodSelector({
    required this.isDark,
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    const periods = ['day', 'week', 'month', 'year'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
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
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: periods.map((period) {
          final isSelected = currentPeriod == period;
          return InkWell(
            onTap: () => onPeriodChanged(period),
            borderRadius: BorderRadius.circular(20.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? AppColors.darkThemeContainerColorElevated
                          : AppColors.backGroundColorLight)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? (isDark
                            ? Colors.white.withOpacity(0.14)
                            : AppColors.darkBrown.withOpacity(0.18))
                      : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.darkBrown.withOpacity(0.1)),
                ),
              ),
              child: Text(
                period.toUpperCase(),
                style: AppFonts.body(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown)
                      : (isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor.withOpacity(0.75)),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatsSummaryCard extends StatelessWidget {
  final bool isDark;
  final int totalOrders;
  final double totalRevenue;
  final String period;

  const _StatsSummaryCard({
    required this.isDark,
    required this.totalOrders,
    required this.totalRevenue,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'orders.performanceSummary'.tr(),
                style: AppFonts.heading(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkGreyTextColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.darkBrown.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  period.toUpperCase(),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  isDark: isDark,
                  icon: Icons.shopping_bag_outlined,
                  title: 'orders.ordersTitle'.tr(),
                  value: '$totalOrders',
                  color: AppColors.darkBrown,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricTile(
                  isDark: isDark,
                  icon: Icons.payments_outlined,
                  title: 'orders.revenue'.tr(),
                  value: totalRevenue.toStringAsFixed(2),
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkThemeContainerColorElevated
            : AppColors.backGroundColorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17.sp),
              SizedBox(width: 6.w),
              Text(
                title,
                style: AppFonts.body(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGreyColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppFonts.heading(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatsEntryCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final int orders;
  final double amount;

  const _StatsEntryCard({
    required this.isDark,
    required this.label,
    required this.orders,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.primaryColor.withOpacity(0.14),
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
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkGreyTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  '$orders orders',
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: AppColors.textGreyColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            amount.toStringAsFixed(2),
            style: AppFonts.heading(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStatsBreakdownCard extends StatelessWidget {
  final bool isDark;

  const _NoStatsBreakdownCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.primaryColor.withOpacity(0.14),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 32.sp,
            color: AppColors.textGreyColor,
          ),
          SizedBox(height: 10.h),
          Text(
            'orders.noEntriesForPeriod'.tr(),
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 13.sp,
              color: AppColors.textGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}
