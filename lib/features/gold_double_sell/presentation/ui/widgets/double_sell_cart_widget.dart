import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart';

class DoubleSellCartWidget extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<DoubleSellCartItemModel> items;
  final ValueChanged<int> onRemove;
  final void Function(int index, double newPrice)? onPriceChanged;

  const DoubleSellCartWidget({
    super.key,
    required this.title,
    required this.accentColor,
    required this.items,
    required this.onRemove,
    this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = items.fold<double>(0.0, (sum, item) => sum + item.price);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : accentColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppFonts.heading(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkBrown,
                ),
              ),
              const Spacer(),
              Text(
                'Total ${total.toStringAsFixed(2)}',
                style: AppFonts.body(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : AppColors.backGroundColorLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'common.noItemsAdded'.tr(),
                style: AppFonts.body(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                ),
              ),
            )
          else
            Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 8.h,
                  ),
                  child: DoubleSellCartItemCard(
                    item: item,
                    accentColor: accentColor,
                    priceEditable: onPriceChanged != null,
                    onPriceChanged: (value) =>
                        onPriceChanged?.call(index, value),
                    onDelete: () => onRemove(index),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
