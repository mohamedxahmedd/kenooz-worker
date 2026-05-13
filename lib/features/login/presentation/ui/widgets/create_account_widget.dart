import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';


class CreateAccountWidget extends StatelessWidget {
  const CreateAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("signin.dontHaveAccount".tr(),
            style: TextStyles.textStyle14.copyWith(
              fontSize: 12.sp,
            )),
        TextButton(
            onPressed: () {
              context.pushNamed(Routes.signupScreen);
            },
            child: Text('signin.createAccount'.tr(),
                style: TextStyles.textStyle12.copyWith(
                  color: AppColors.greenColor,
                  fontWeight: FontWeight.w600,
                ))),
      ],
    );
  }
}
