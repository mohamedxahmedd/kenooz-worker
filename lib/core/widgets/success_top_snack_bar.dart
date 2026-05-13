import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_snack_bar.dart';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

void successSnackBar({required String msg, required BuildContext context}) =>
    showTopSnackBar(
      dismissType: DismissType.onSwipe,
      displayDuration: const Duration(seconds: 1),
      Overlay.of(context),
      GlobalSnackBar.success(
        iconRotationAngle: 0,
        icon: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Image.asset(
            Assets.assetsImagesLogo,
            color: Colors.white,
            width: 100.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
        ),
        gradient: [AppColors.darkBrown, AppColors.goldColor],
        message: msg,
      ),
    );
