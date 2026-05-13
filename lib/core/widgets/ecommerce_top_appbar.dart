import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/glassmorphism_container.dart';


class EcommerceTopAppBar extends StatelessWidget {
  const EcommerceTopAppBar({
    super.key,
    required this.hasGlassBackground,
    this.showBackButton = false,
    this.showCartIcon = true,
    this.showShopButton = false,
  });

  final bool hasGlassBackground;
  final bool showBackButton;
  final bool showCartIcon;
  final bool showShopButton;

  @override
  Widget build(BuildContext context) {
    final topBar = SizedBox(
      height: 50.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            horizontalSpace(5.w),
            if (showBackButton)
              GestureDetector(
                onTap: context.pop,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 30.h,
                  color: AppColors.primaryColor,
                ),
              ),
            if (showBackButton) horizontalSpace(8.w),
            Image.asset(Assets.assetsImagesLogo, height: 37.h),
            const Spacer(),
            if (showCartIcon)
              GestureDetector(
                onTap: () => context.pushNamed(Routes.cartScreen),
                child: GlassmorphismContainer(
                  height: 25.h,
                  width: 25.w,
                  borderRadius: 18.r,
                  child: Center(
                    child: Image.asset(
                      'assets/images/shopping-cart.png',
                      height: 20.h,
                      width: 20.w,
                    ),
                  ),
                ),
              ),
            if (showCartIcon && showShopButton) horizontalSpace(12.w),
            if (showShopButton)
              GestureDetector(
                onTap: () => context.pushNamed(Routes.shopScreen),
                child: Container(
                  height: 35.h,
                  width: 82.w,
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    children: [
                      horizontalSpace(12.w),
                      Text(
                        'Shop',
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      horizontalSpace(6.w),
                      GlassmorphismContainer(
                        height: 20.h,
                        width: 20.w,
                        child: Center(
                          child: Image.asset(
                            'assets/images/favicon.png',
                            height: 12.h,
                            width: 12.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (hasGlassBackground) {
      return GlassmorphismContainer(
        height: 52.h,
        gradientColors: [
          AppColors.yellowColor.withValues(alpha: 0.1),
          AppColors.yellowColor.withValues(alpha: 0.1),
        ],
        child: topBar,
      );
    }

    return topBar;
  }
}
