import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_cubit.dart';

class HomeUsdRateWidget extends StatelessWidget {
  final double usdRate;
  final bool isDark;

  const HomeUsdRateWidget({
    super.key,
    required this.usdRate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
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
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            
            child: Center(
              child: SvgPicture.asset(
                Assets.assetsImagesHomeUsdIcon,
                width: 45.sp,
                height: 45.sp,
                
              ),
            ),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home_worker.usdRate'.tr(),
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGreyColor,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      usdRate.toStringAsFixed(2),
                      style: AppFonts.heading(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkGreyTextColor,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Text(
                        'common.egp'.tr(),
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGreyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'home_worker.liveConversionBasis'.tr(),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGreyColor,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => _showEditBottomSheet(context),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBrown.withOpacity(0.3)
                    : AppColors.darkBrown.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.darkBrown.withOpacity(0.14),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  Assets.assetsImagesEditTextIcon,
                  width: 18.sp,
                  height: 18.sp,
                  colorFilter: ColorFilter.mode(
                    isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    final cubit = context.read<UpdateRatesCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _UsdEditSheet(isDark: isDark),
      ),
    );
  }
}

// ── USD Edit Bottom Sheet ────────────────────────────────────────────────────

class _UsdEditSheet extends StatelessWidget {
  final bool isDark;
  const _UsdEditSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UpdateRatesCubit>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : AppColors.primaryColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                       
                        child: Center(
                          child: SvgPicture.asset(
                            Assets.assetsImagesHomeUsdIcon,
                            width: 18.sp,
                            height: 18.sp,
                           
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'home_worker.updateUsdRate'.tr(),
                        style: AppFonts.heading(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Form
                  Form(
                    key: cubit.usdFormKey,
                    child: TextFormField(
                      controller: cubit.usdController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,4}'),
                        ),
                      ],
                      style: AppFonts.body(
                        fontSize: 15.sp,
                        color: isDark
                            ? AppColors.lightTextColorForDarkMood
                            : AppColors.darkGreyTextColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'home_worker.newUsdRate'.tr(),
                        labelStyle: AppFonts.body(
                          fontSize: 13.sp,
                          color: AppColors.textGreyColor,
                        ),
                        hintText: 'home_worker.egExample'.tr(),
                        hintStyle: AppFonts.body(
                          fontSize: 13.sp,
                          color: AppColors.textGreyColor.withOpacity(0.5),
                        ),
                        suffixText: 'common.egp'.tr(),
                        suffixStyle: AppFonts.body(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGreyColor,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkThemeContainerColorElevated
                            : AppColors.creamyColor.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : AppColors.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: AppColors.errorColor,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: AppColors.errorColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'home_worker.pleaseEnterUsdRate'.tr();
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'common.enterValidPositiveNumber'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? AppColors.textGreyColor
                                : AppColors.darkGreyTextColor,
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : AppColors.primaryColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'common.cancel'.tr(),
                            style: AppFonts.body(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            cubit.emitUpdateUsdStates();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'common.update'.tr(),
                            style: AppFonts.body(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
