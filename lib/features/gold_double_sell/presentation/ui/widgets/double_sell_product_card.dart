import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_product_model.dart';

class DoubleSellProductCard extends StatelessWidget {
  final GoldProductModel product;
  final double price;

  const DoubleSellProductCard({
    super.key,
    required this.product,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.goldColor.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: _buildImage(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Carat: ${product.caratName.isEmpty ? product.caratLabel : product.caratName}',
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Grams: ${product.grams.toStringAsFixed(2)}',
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Price: ${price.toStringAsFixed(2)}',
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (product.media.isNotEmpty) {
      return Image.network(
        product.media.first,
        width: 68.w,
        height: 68.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 68.w,
      height: 68.w,
      color: AppColors.backGroundColorLight,
      child: Icon(
        Icons.inventory_2_rounded,
        size: 28.sp,
        color: AppColors.darkBrown,
      ),
    );
  }
}
