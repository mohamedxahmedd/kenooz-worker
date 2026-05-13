import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_full_history_model.dart';

class SilverBuyHistoryCard extends StatelessWidget {
  final SilverBuyFullHistoryModel buy;

  const SilverBuyHistoryCard({super.key, required this.buy});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.silverColor;

    final sourceName = buy.hasClient
        ? buy.client!.name
        : buy.hasVendor
        ? buy.vendor!.name
        : 'Unknown';
    final sourceSubtitle = buy.hasClient
        ? buy.client!.phone
        : buy.hasVendor
        ? 'common.vendor'.tr()
        : '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.silverColor.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
               
                child: SvgPicture.asset('assets/images/silver-bars.svg'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sourceName,
                      style: AppFonts.heading(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.silverColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sourceSubtitle.isNotEmpty
                          ? '$sourceSubtitle  •  Buy #${buy.id}'
                          : 'Buy #${buy.id}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${buy.total.toStringAsFixed(2)} ${'common.egp'.tr()}',
                    style: AppFonts.heading(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatDate(buy.createdAt),
                    style: AppFonts.body(
                      fontSize: 10.sp,
                      color: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.silverColor.withOpacity(0.16),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: '${buy.itemCount} item${buy.itemCount != 1 ? 's' : ''}',
                isDark: isDark,
                accentColor: accentColor,
              ),
              SizedBox(width: 8.w),
              _InfoChip(
                icon: Icons.person_outline_rounded,
                label: buy.worker.name,
                isDark: isDark,
                accentColor: accentColor,
              ),
              if (buy.isLinkedToSell) ...[
                SizedBox(width: 8.w),
                _InfoChip(
                  icon: Icons.link_rounded,
                  label: 'silver_buy.sellRecord'.tr() + ' #${buy.sellId}',
                  isDark: isDark,
                  accentColor: accentColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color accentColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: accentColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
