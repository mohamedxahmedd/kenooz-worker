import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/home/data/models/carat_model.dart';
import 'package:kenooz_worker_app/features/home/data/models/gold_rates_model.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_cubit.dart';

class HomeGoldRateWidget extends StatelessWidget {
  final GoldRatesModel goldRates;
  final bool isDark;

  const HomeGoldRateWidget({
    super.key,
    required this.goldRates,
    required this.isDark,
  });

  // Gold accent color
  static const Color _goldAccent = Color(0xFFB8860B);

  CaratModel? _gold21Carat() {
    for (final carat in goldRates.carats) {
      final digitsOnly = carat.carat.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly == '21') return carat;
    }
    return goldRates.carats.isNotEmpty ? goldRates.carats.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final primaryCarat = _gold21Carat();

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
                Assets.assetsImagesHomeGoldIcon,
                width: 50.sp,
                height: 50.sp,
               
              ),
            ),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home_worker.goldRate'.tr(),
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
                      primaryCarat?.price.toStringAsFixed(2) ?? '--',
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
                  primaryCarat == null
                      ? 'home_worker.noGoldRateAvailable'.tr()
                      : '${primaryCarat.carat} ${'common.carat'.tr()}',
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
                    ? _goldAccent.withOpacity(0.15)
                    : _goldAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _goldAccent.withOpacity(0.14)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  Assets.assetsImagesEditTextIcon,
                  width: 18.sp,
                  height: 18.sp,
                  colorFilter: const ColorFilter.mode(
                    _goldAccent,
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
        child: _GoldEditSheet(isDark: isDark),
      ),
    );
  }
}

// ── Gold Edit Bottom Sheet ───────────────────────────────────────────────────

class _GoldEditSheet extends StatelessWidget {
  final bool isDark;
  const _GoldEditSheet({required this.isDark});

  static const Color _goldAccent = Color(0xFFB8860B);

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
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                       
                        child: Center(
                          child: SvgPicture.asset(
                            Assets.assetsImagesHomeGoldIcon,
                            width: 50.sp,
                            height: 50.sp,
                            
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'home_worker.updateGoldPrice21K'.tr(),
                        style: AppFonts.heading(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'home_worker.otherCaratsCalculated'.tr(),
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      color: AppColors.textGreyColor,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  Form(
                    key: cubit.goldFormKey,
                    child: TextFormField(
                      controller: cubit.goldController,
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
                        labelText: 'home_worker.pricePerGram21K'.tr(),
                        labelStyle: AppFonts.body(
                          fontSize: 13.sp,
                          color: AppColors.textGreyColor,
                        ),
                        hintText: 'home_worker.egGoldExample'.tr(),
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
                            color: _goldAccent,
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
                          return 'home_worker.pleaseEnterGoldPrice'.tr();
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
                            cubit.emitUpdateGoldStates();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _goldAccent,
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
