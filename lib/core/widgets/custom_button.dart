import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/core/theming/themes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final BorderSide? borderSide;
  final double? elevation;
  final bool? enableShadow;
  final bool? isEnabled;
  final List<Color>? gradientColors;

  final List<BoxShadow>? boxShadow;
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 8.0,
    this.borderSide,
    this.elevation,
    this.enableShadow,
    this.isEnabled,
    this.boxShadow,
    this.textStyle,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = tokensOf(context);
    final hasGradient = gradientColors != null && gradientColors!.length >= 2;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.9,
        height: height ?? 60.h,
        margin: margin,
        decoration: BoxDecoration(
          gradient: hasGradient
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderSide?.color ?? Colors.transparent,
            width: borderSide?.width ?? 0.0,
          ),
          color: hasGradient ? null : (color ?? tokens.buttonBg),
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: Colors.grey.withAlpha(77),
                  spreadRadius: -1,
                  blurRadius: 5.sp,
                ),
              ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyles.textStyle16.copyWith(
              color: textColor ?? tokens.buttonFg,
              fontSize: fontSize ?? 15.sp,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
