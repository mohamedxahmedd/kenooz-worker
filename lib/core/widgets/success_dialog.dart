import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';


// ignore: must_be_immutable
class SuccessDialog extends StatelessWidget {
  SuccessDialog(
      {super.key, required this.isMedicine, this.message, this.onTap});
  bool isMedicine;
  String? message;
  VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
            color: (context.read<SettingsCubit>().isDark)
                ? AppColors.darkThemeBackgroundColor
                : Colors.white,
            borderRadius: BorderRadius.circular(30.sp)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(10),
            Row(
              children: [
                SvgPicture.asset(Assets.assetsImagesSuccessIcon, width: 35.w),
                horizontalSpace(15),
                (isMedicine)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "dialoge.takeMedicine".tr(),
                            style: TextStyles.textStyle14,
                          ),
                          Text(
                            "dialoge.areYouSureToTakeMedicine".tr(),
                            style: TextStyles.textStyle12,
                          ),
                        ],
                      )
                    : SizedBox(
                        width: 200.w,
                        child: Text(
                          message!,
                          style: TextStyles.textStyle14,
                        ),
                      ),
              ],
            ),
            verticalSpace(10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              width: double.infinity,
              height: 0.8,
              color: Colors.grey.shade300,
            ),
            verticalSpace(5),
            (isMedicine)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 13.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'dialoge.cancel'.tr(),
                            style: TextStyles.textStyle12.copyWith(
                                color: (context.read<SettingsCubit>().isDark)
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                      horizontalSpace(10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 13.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.secondryColor
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'dialoge.success'.tr(),
                            style: TextStyles.textStyle12.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: onTap ??
                        () {
                          context.pop();
                        },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 30.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondryColor
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(17.r),
                      ),
                      height: 45.h,
                      child: Text(
                        "dialoge.done".tr(),
                        style: TextStyles.textStyle14
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
