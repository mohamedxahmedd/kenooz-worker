import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';



class LoginDialougWidget extends StatelessWidget {
  const LoginDialougWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Center(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15.r)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    children: [
                      verticalSpace(5),
                      Center(
                        child: Text(
                          "Login to make a booking".tr(),
                          style: TextStyles.textStyle14.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      verticalSpace(15),
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "you need to be logged in to make this action".tr(),
                          style: TextStyles.textStyle11
                              .copyWith(color: AppColors.textGreyColor),
                        ),
                      ),
                      verticalSpace(25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            width: 60.w,
                            height: 25.h,
                            text: "Login".tr(),
                            fontSize: 12.sp,
                            onPressed: () {
                              context.pushNamed(Routes.loginScreen);
                            },
                          ),
                          horizontalSpace(15),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 60.w,
                              height: 25.h,
                              //  color: Colors.red,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Center(
                                child: Text("Cancel".tr(),
                                    style: TextStyles.textStyle12.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(5),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
