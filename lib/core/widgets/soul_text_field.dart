import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

/// A themed text form field used throughout the Soul checkout flow.
///
/// Shows a label above the field and a prefixed icon inside it.
/// Automatically adapts fill/border colours to [isDark].
class SoulTextField extends StatelessWidget {
  const SoulTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final fillColor =
        isDark ? AppColors.darkThemeContainerColor : AppColors.creamyColor;
    final labelColor = isDark
        ? AppColors.lightTextColorForDarkMood
        : AppColors.darkGreyTextColor;
    final textColor = isDark ? Colors.white : AppColors.primaryColor;
    final hintColor = isDark
        ? AppColors.textGreyColor.withOpacity(0.7)
        : AppColors.darkGreyTextColor.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.body(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.3,
          ),
        ),
        verticalSpace(6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppFonts.body(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.body(fontSize: 13.sp, color: hintColor),
            prefixIcon: Icon(
              icon,
              size: 18.sp,
              color: AppColors.darkBrown.withOpacity(0.7),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : AppColors.creamyColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: AppColors.darkBrown.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: AppColors.errorColor.withOpacity(0.8),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.errorColor),
            ),
            errorStyle: AppFonts.body(
              fontSize: 10.sp,
              color: AppColors.errorColor,
            ),
          ),
        ),
      ],
    );
  }
}
