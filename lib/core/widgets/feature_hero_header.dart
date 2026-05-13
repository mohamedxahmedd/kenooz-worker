import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/glassmorphism_container.dart';


/// A full-width hero banner reused on Cart, Orders, Profile, Search, and
/// Checkout screens. It shows `assets/images/shop1.webp` with a dark
/// overlay, a glassmorphic breadcrumb chip, a large [title], and a [subtitle].
class FeatureHeroHeader extends StatelessWidget {
  const FeatureHeroHeader({
    super.key,
    required this.breadcrumb,
    required this.title,
    required this.subtitle,
    this.height,
    this.titleAlignment = CrossAxisAlignment.center,
  });

  /// Short breadcrumb text shown in the top chip, e.g. "Home > Cart".
  final String breadcrumb;

  /// Large heading displayed near the bottom of the banner.
  final String title;

  /// Smaller descriptive line shown below [title].
  final String subtitle;

  /// Banner height. Defaults to 165.h.
  final double? height;

  /// Alignment for the title / subtitle column. Use [CrossAxisAlignment.center]
  /// for Orders; [CrossAxisAlignment.start] (default) for others.
  final CrossAxisAlignment titleAlignment;

  @override
  Widget build(BuildContext context) {
    final bannerHeight = height ?? 165.h;
    // Breadcrumb chip width = breadcrumb text length * ~7.5 logical pixels
    final chipWidth = (breadcrumb.length * 7.0).clamp(100.0, 200.0).w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: SizedBox(
          height: bannerHeight,
          width: double.infinity,
          child: Stack(
            children: [
              // ── Background image ───────────────────────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/images/shop1.webp',
                  fit: BoxFit.cover,
                ),
              ),

              // ── Dark overlay ───────────────────────────────────────────
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 18.h,
                  ),
                  child: Column(
                    crossAxisAlignment: titleAlignment,
                    children: [
                      // Breadcrumb chip
                      GlassmorphismContainer(
                        height: 26.h,
                        width: chipWidth,
                        child: Center(
                          child: Text(
                            breadcrumb,
                            style: AppFonts.body(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        textAlign: titleAlignment == CrossAxisAlignment.center
                            ? TextAlign.center
                            : TextAlign.start,
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      verticalSpace(6.h),
                      Text(
                        subtitle,
                        textAlign: titleAlignment == CrossAxisAlignment.center
                            ? TextAlign.center
                            : TextAlign.start,
                        style: AppFonts.body(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
