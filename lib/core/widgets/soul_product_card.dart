import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/glassmorphism_container.dart';

/// A unified product card used across Home (featured & all products)
/// and Shop (category products). Pass [showBadge] = true to show the
/// coloured label in the top-left corner.
///
/// **Sizing modes:**
/// - **Fixed** (default in horizontal lists): uses default 180.w × 220.h.
/// - **Expand** (grids): set [expandToParent] = true so the card fills
///   whatever space its parent (e.g. `GridView`) allocates.
class SoulProductCard extends StatelessWidget {
  const SoulProductCard({
    super.key,
    required this.imagePath,
    required this.category,
    required this.name,
    required this.price,
    this.showBadge = false,
    this.badgeLabel = 'Featured',
    this.cardWidth,
    this.cardHeight,
    this.overlayWidth,
    this.expandToParent = false,
  });

  final String imagePath;
  final String category;
  final String name;
  final String price;
  final bool showBadge;
  final String badgeLabel;
  final double? cardWidth;
  final double? cardHeight;
  final double? overlayWidth;

  /// When true the card ignores [cardWidth]/[cardHeight] and stretches to
  /// fill its parent — perfect for GridView cells.
  final bool expandToParent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cWidth = expandToParent ? double.infinity : (cardWidth ?? 180.w);
    final cHeight = expandToParent ? double.infinity : (cardHeight ?? 220.h);

    return GestureDetector(
      onTap: () => context.pushNamed(Routes.productDetailsScreen),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // When expanding, derive overlay width from actual parent width.
          final actualWidth = expandToParent
              ? constraints.maxWidth
              : (cardWidth ?? 180.w);
          final oWidth = overlayWidth ?? (actualWidth * 0.78);

          // When expanding, derive overlay height proportionally.
          final actualHeight = expandToParent
              ? constraints.maxHeight
              : (cardHeight ?? 232.h);
          final oHeight = actualHeight * 0.35;

          return Stack(
            children: [
              // ── Product image ────────────────────────────────────────
              Container(
                height: cHeight,
                width: cWidth,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),

              // ── Optional badge (e.g. "Featured") ────────────────────
              if (showBadge)
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldColor,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      badgeLabel,
                      style: AppFonts.heading(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // ── Info overlay — adapts between light & dark ──────────
              Positioned(
                bottom: 8.h,
                left: 8.w,
                child: GlassmorphismContainer(
                  
                  isDark: isDark,
                  borderRadius: 10.r,
                  gradientColors: isDark
                      ? [
                          const Color(0xFF0E1B14).withValues(alpha: 0.90),
                          const Color(0xFF0E1B14).withValues(alpha: 0.90),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.72),
                          Colors.white.withValues(alpha: 0.72),
                        ],
                  height: oHeight,
                  width: oWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      verticalSpace(5.h),
                      Padding(
                        padding: EdgeInsets.only(left: 7.w),
                        child: Text(
                          category,
                          style: AppFonts.body(
                            color: isDark
                                ? AppColors.goldColor.withValues(alpha: 0.85)
                                : AppColors.darkBrown,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 7.w),
                        child: Text(
                          name,
                          style: AppFonts.heading(
                            color: isDark
                                ? AppColors.lightTextColorForDarkMood
                                : AppColors.primaryColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(left: 7.w, bottom: 5.h),
                        child: Text(
                          price,
                          style: AppFonts.heading(
                            color: isDark
                                ? AppColors.goldColor
                                : AppColors.darkBrown,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
