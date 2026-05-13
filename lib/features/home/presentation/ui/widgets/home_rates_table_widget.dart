import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/home/data/models/carat_model.dart';

class HomeRatesTableWidget extends StatelessWidget {
  final List<CaratModel> carats;
  final bool isDark;

  const HomeRatesTableWidget({
    super.key,
    required this.carats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.primaryColor.withOpacity(0.14),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBrown.withOpacity(0.35)
                    : AppColors.darkBrown.withOpacity(0.06),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'common.carat'.tr(),
                      style: AppFonts.body(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'common.fixed'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'common.price'.tr(),
                      textAlign: TextAlign.right,
                      style: AppFonts.body(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkBrown,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...carats.asMap().entries.map((entry) {
              final index = entry.key;
              final carat = entry.value;
              final isEven = index.isEven;
              final showDivider = index < carats.length - 1;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isEven
                      ? (isDark
                            ? Colors.white.withOpacity(0.03)
                            : AppColors.creamyColor.withOpacity(0.32))
                      : Colors.transparent,
                  border: showDivider
                      ? Border(
                          bottom: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : AppColors.primaryColor.withOpacity(0.1),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : AppColors.darkBrown.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : AppColors.darkBrown.withOpacity(0.12),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          carat.carat,
                          style: AppFonts.body(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.darkBrown,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        carat.fixed.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        carat.price.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: AppFonts.body(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.goldColor
                              : AppColors.darkBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
