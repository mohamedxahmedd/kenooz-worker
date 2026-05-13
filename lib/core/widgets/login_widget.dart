import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';



class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("loginWidget.pleaseLoginToLoadData".tr(),
              style: TextStyles.textStyle14.copyWith(
                fontWeight: FontWeight.w600,
              )),
          verticalSpace(20),
          CustomButton(
              borderRadius: 30.r,
              height: 50.h,
              width: 200.w,
              text: "loginWidget.login".tr(),
              onPressed: () {
                context.pushNamed(Routes.loginScreen);
              }),
        ],
      ),
    );
  }
}
