import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';

class SignInTitle extends StatelessWidget {
  const SignInTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        verticalSpace(50.h),
        Image.asset(Assets.assetsImagesLogo, width: 170.w),
        verticalSpace(20.h),
        Center(child: Text("signin.signin".tr(), style: TextStyles.heading24)),
      ],
    );
  }
}
