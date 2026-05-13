import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';



class LoginTextButtonWidget extends StatelessWidget {
  const LoginTextButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("signup.alreadyHaveAccount".tr(),
            style: TextStyles.textStyle14.copyWith(
              fontSize: 12.sp,
            )),
        TextButton(
            onPressed: () {
              context.pushNamed(Routes.loginScreen);
            },
            child: Text('signup.signin'.tr(),
                style: TextStyles.textStyle12.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ))),
      ],
    );
  }
}
