import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/ui/widgets/silver_buy_product_card.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/ui/widgets/silver_buy_product_form_sheet.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_box_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';

class SilverBuyProductSection extends StatelessWidget {
  final List<SilverCaratModel> carats;
  final List<SilverBoxModel> boxes;
  final List<Map<String, dynamic>> products;
  final ValueChanged<Map<String, dynamic>> onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onCreateCarat;

  const SilverBuyProductSection({
    Key? key,
    required this.carats,
    required this.boxes,
    required this.products,
    required this.onAdd,
    required this.onRemove,
    required this.onCreateCarat,
  }) : super(key: key);

  void _openProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SilverBuyProductFormSheet(
        carats: carats,
        boxes: boxes,
        onCreateCarat: () {
          Navigator.pop(context);
          onCreateCarat();
        },
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        onAdd(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.silverColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'silver_buy.products'.tr(),
                style: AppFonts.heading(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.silverColor,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.silverColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${products.length}',
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.silverColor,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCreateCarat,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.silverColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.silverColor.withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_fix_high_rounded,
                        size: 14.sp,
                        color: AppColors.silverColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'silver_buy.addCarat'.tr(),
                        style: AppFonts.body(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.silverColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openProductForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.silverColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('silver_buy.addProduct'.tr()),
            ),
          ),
          SizedBox(height: 12.h),
          if (products.isEmpty)
            Text(
              'silver_buy.noProductsAdded'.tr(),
              style: AppFonts.body(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
            )
          else
            Column(
              children: List.generate(products.length, (index) {
                final product = products[index];
                return SilverBuyProductCard(
                  product: product,
                  onRemove: () => onRemove(index),
                );
              }),
            ),
        ],
      ),
    );
  }
}
