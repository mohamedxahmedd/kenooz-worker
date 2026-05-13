import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';



class ForgetPassWidget extends StatelessWidget {
  const ForgetPassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: CacheHelper.isEnglish()
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: TextButton(
          onPressed: () {},
          child: Text(
            'signin.forgotPassword'.tr(),
            style: TextStyles.textStyle14.copyWith(
              color: AppColors.primaryColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
  }
}
