import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_product_model.dart';

class DiamondSellProductCard extends StatelessWidget {
  final String productType; // 'diamond' or 'stone'
  final DiamondProductModel? diamond;
  final StoneProductModel? stone;
  final double egpPrice;
  final VoidCallback? onAdd;

  const DiamondSellProductCard({
    super.key,
    required this.productType,
    this.diamond,
    this.stone,
    required this.egpPrice,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const diamondAccent = Color(0xFF64B5F6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : diamondAccent.withOpacity(0.18),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _name,
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
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: productType == 'diamond'
                            ? diamondAccent.withOpacity(0.15)
                            : Colors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        productType == 'diamond' ? 'Diamond' : 'Stone',
                        style: AppFonts.body(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: productType == 'diamond'
                              ? diamondAccent
                              : Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  _subtitle,
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'USD: \$${_usdPrice.toStringAsFixed(2)}',
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'EGP: ${egpPrice.toStringAsFixed(2)}',
                        style: AppFonts.body(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successColor,
                        ),
                      ),
                    ),
                    if (onAdd != null)
                      SizedBox(
                        height: 34.h,
                        child: ElevatedButton.icon(
                          onPressed: onAdd,
                          icon: Icon(Icons.add_rounded, size: 16.sp),
                          label: Text(
                            'Add',
                            style: AppFonts.body(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBrown,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _name {
    if (productType == 'diamond') return diamond?.name ?? '';
    return stone?.name ?? '';
  }

  String get _subtitle {
    if (productType == 'diamond' && diamond != null) {
      return 'Diamond: ${diamond!.totalDWeight.toStringAsFixed(3)} ct  •  Gold: ${diamond!.totalGWeight.toStringAsFixed(3)} g';
    }
    if (stone != null) {
      return 'Weight: ${stone!.weight.toStringAsFixed(2)} ct  •  Report: ${stone!.reportNumber}';
    }
    return '';
  }

  double get _usdPrice {
    if (productType == 'diamond') return diamond?.total ?? 0;
    return stone?.price ?? 0;
  }

  List<String> get _media {
    if (productType == 'diamond') return diamond?.media ?? [];
    return stone?.media ?? [];
  }

  Widget _buildImage() {
    if (_media.isNotEmpty) {
      return Image.network(
        _media.first,
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
        productType == 'diamond'
            ? Icons.diamond_rounded
            : Icons.hexagon_rounded,
        size: 28.sp,
        color: AppColors.darkBrown,
      ),
    );
  }
}
