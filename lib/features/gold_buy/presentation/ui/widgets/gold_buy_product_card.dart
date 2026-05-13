import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';

class GoldBuyProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onRemove;

  const GoldBuyProductCard({
    Key? key,
    required this.product,
    required this.onRemove,
  }) : super(key: key);

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final caratLabel = product['carat_label'] as String? ?? '';
    final boxName = product['box_name'] as String? ?? '';
    final grams = _toDouble(product['grams']);
    final loss = _toDouble(product['loss']);
    final gramPrice = _toDouble(product['gram_price']);
    final buyPrice = _toDouble(product['buy_price']);
    final net = (grams - loss).clamp(0, double.infinity).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkThemeContainerColorElevated
            : AppColors.backGroundColorLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$caratLabel • $boxName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.goldColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${grams.toStringAsFixed(2)}g',
                        style: AppFonts.body(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.goldColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.goldColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${'common.loss'.tr()} ${loss.toStringAsFixed(2)}g',
                        style: AppFonts.body(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.goldColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.goldColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'gold_buy.net'.tr() + ' ${net.toStringAsFixed(2)}g',
                        style: AppFonts.body(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.goldColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.goldColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${gramPrice.toStringAsFixed(2)}/g',
                        style: AppFonts.body(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.goldColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${buyPrice.toStringAsFixed(2)}',
                style: AppFonts.body(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkBrown,
                ),
              ),
              Text(
                'common.egp'.tr(),
                style: AppFonts.body(
                  fontSize: 10.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.errorColor,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
