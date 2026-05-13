import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_unified_sell_history_model.dart';

class DiamondSellHistoryCard extends StatelessWidget {
  final DiamondUnifiedSellHistoryModel sell;

  const DiamondSellHistoryCard({super.key, required this.sell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFF64B5F6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.14),
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
              
                child: SvgPicture.asset('assets/images/diamond.svg'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sell.client.name,
                      style: AppFonts.heading(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Sell ${sell.unifiedId.length > 8 ? sell.unifiedId.substring(0, 8) : sell.unifiedId}...',
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
                    '\$${sell.grandTotal.toStringAsFixed(2)}',
                    style: AppFonts.heading(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sell.sellDate,
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
                : AppColors.primaryColor.withOpacity(0.12),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              if (sell.totalDiamondItems > 0) ...[
                _InfoChip(
                  icon: Icons.diamond_outlined,
                  label: '${sell.totalDiamondItems} diamonds',
                  accentColor: accentColor,
                ),
                SizedBox(width: 8.w),
              ],
              if (sell.totalStoneItems > 0) ...[
                _InfoChip(
                  icon: Icons.circle_outlined,
                  label: '${sell.totalStoneItems} stones',
                  accentColor: accentColor,
                ),
                SizedBox(width: 8.w),
              ],
              _InfoChip(
                icon: Icons.person_outline_rounded,
                label: sell.worker.name,
                accentColor: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _InfoChip({
    required this.icon,
    required this.label,
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
