import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable glassmorphism container widget that creates a frosted glass effect
/// with backdrop blur, gradient background, and customizable border.
///
/// This widget is inspired by the glassmorphism design trend and provides
/// a modern, elegant UI component that can be used across different projects.
///
/// Example usage:
/// ```dart
/// GlassmorphismContainer(
///   child: Text('Hello World'),
///   isDark: true,
/// )
/// ```
class GlassmorphismContainer extends StatelessWidget {
  /// The child widget to be displayed inside the glassmorphism container
  final Widget child;

  /// Whether the app is in dark mode or light mode
  /// This affects the gradient colors and opacity values
  final bool isDark;

  /// The border radius of the container
  /// Default is 24.0
  final double borderRadius;

  /// The blur intensity for the backdrop filter
  /// Higher values create more blur. Default is 10.0
  final double blurIntensity;

  /// Custom gradient colors for the glassmorphism effect
  /// If null, default colors based on isDark will be used
  final List<Color>? gradientColors;

  /// The width of the border
  /// Default is 1.5
  final double borderWidth;

  /// The opacity of the border color
  /// Default is 0.2
  final double borderOpacity;

  /// Whether to add a shadow to the container
  /// Default is true
  final bool addShadow;

  /// The shadow color when addShadow is true
  /// Default is black with 0.1 opacity
  final Color? shadowColor;

  /// The blur radius of the shadow
  /// Default is 10.0
  final double shadowBlurRadius;

  /// The offset of the shadow
  /// Default is Offset(0, 4)
  final Offset shadowOffset;

  /// Padding inside the container
  /// If null, no padding is applied
  final EdgeInsetsGeometry? padding;

  /// Margin outside the container
  /// If null, no margin is applied
  final EdgeInsetsGeometry? margin;

  /// Width of the container
  /// If null, the container will expand to fill available space
  final double? width;

  /// Height of the container
  /// If null, the container will size itself to the child
  final double? height;

  /// Custom border for the container
  /// If null, a default border based on borderWidth and borderOpacity will be used
  final Border? customBorder;

  /// The clip behavior for the container
  /// Default is Clip.antiAlias
  final Clip clipBehavior;

  /// Creates a glassmorphism container with customizable properties
  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.isDark = false,
    this.borderRadius = 24.0,
    this.blurIntensity = 10.0,
    this.gradientColors,
    this.borderWidth = 1.5,
    this.borderOpacity = 0.2,
    this.addShadow = true,
    this.shadowColor,
    this.shadowBlurRadius = 10.0,
    this.shadowOffset = const Offset(0, 4),
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.customBorder,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    // Default gradient colors based on theme
    final defaultGradientColors = isDark
        ? [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)]
        : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)];

    // NOTE: width/height are used AS-IS (no .w/.h) because callers
    // already pass pre-scaled values.  Applying .w/.h here would
    // double-scale and cause inconsistent sizing across devices.
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: addShadow
            ? [
                BoxShadow(
                  color: shadowColor ?? Colors.black.withOpacity(0.1),
                  blurRadius: shadowBlurRadius.r,
                  offset: Offset(shadowOffset.dx.w, shadowOffset.dy.h),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity.r,
            sigmaY: blurIntensity.r,
          ),
          child: Container(
            padding: padding,
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? defaultGradientColors,
              ),
              borderRadius: BorderRadius.circular(borderRadius.r),
              border:
                  customBorder ??
                  Border.all(
                    color: Colors.white.withOpacity(borderOpacity),
                    width: borderWidth.r,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A variant of the glassmorphism container with a thicker border
/// Useful for featured or highlighted content
class GlassmorphismContainerFeatured extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final double blurIntensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassmorphismContainerFeatured({
    super.key,
    required this.child,
    this.isDark = false,
    this.borderRadius = 24.0,
    this.blurIntensity = 10.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      isDark: isDark,
      borderRadius: borderRadius,
      blurIntensity: blurIntensity,
      borderWidth: 2.5,
      borderOpacity: 0.3,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// A smaller glassmorphism container with lighter blur
/// Useful for badges, chips, or nested containers
class GlassmorphismContainerLight extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassmorphismContainerLight({
    super.key,
    required this.child,
    this.isDark = false,
    this.borderRadius = 8.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      isDark: isDark,
      borderRadius: borderRadius,
      blurIntensity: 5.0,
      borderWidth: 1.0,
      borderOpacity: 0.2,
      addShadow: false,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      gradientColors: isDark
          ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
          : [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.05)],
      child: child,
    );
  }
}
