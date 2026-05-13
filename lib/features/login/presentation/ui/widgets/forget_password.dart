import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';


import 'package:url_launcher/url_launcher.dart';

class ForgetPassWidget extends StatelessWidget {
  const ForgetPassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: CacheHelper.isEnglish()
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: TextButton(
          onPressed: () async {
            final Uri url =
                Uri.parse('${forgetPasswardUrl}client/forgot-password');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              if (!context.mounted) return;
              failureSnackBar(
                  msg: "appointmentDetails.cantOpenLink".tr(),
                  context: context);
            }
          },
          child: Text(
            "signin.forgotPassword".tr(),
            style: TextStyles.textStyle14.copyWith(
              
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
  }
}
