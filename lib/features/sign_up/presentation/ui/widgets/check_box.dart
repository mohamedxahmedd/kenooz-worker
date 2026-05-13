import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_cubit.dart';
import 'package:url_launcher/url_launcher.dart';



class CheckBoxAndAgreePolicy extends StatefulWidget {
  const CheckBoxAndAgreePolicy({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CheckBoxAndAgreePolicyState createState() => _CheckBoxAndAgreePolicyState();
}

class _CheckBoxAndAgreePolicyState extends State<CheckBoxAndAgreePolicy> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                side: BorderSide(color: Colors.transparent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.r),
                ),
                checkColor: AppColors.primaryColor,
                focusColor: AppColors.primaryColor,
                activeColor: AppColors.primaryColor,
                fillColor: WidgetStateProperty.all(Colors.grey.shade300),
                value: context.read<SignupCubit>().isCheckboxChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    context.read<SignupCubit>().isCheckboxChecked =
                        newValue ?? false; // Update the state
                  });
                },
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: "signup.iAgreeToThe".tr(),
                    style: TextStyles.textStyle11.copyWith(fontSize: 10),
                    children: [
                      TextSpan(
                        text: "signup.termsOfServices".tr(),
                        style: TextStyles.textStyle11.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(
                              Uri.parse('https://kenooz.co/terms'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                      ),
                      TextSpan(
                        text: "signup.and".tr(),
                        style: TextStyles.textStyle11.copyWith(fontSize: 10),
                      ),
                      TextSpan(
                        text: "signup.privacyPolicy".tr(),
                        style: TextStyles.textStyle11.copyWith(
                          fontSize: 10,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(
                              Uri.parse('https://kenooz.co/privacy'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Checkbox(
          //       side: BorderSide(color: Colors.transparent),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(3.r),
          //       ),
          //       checkColor: AppColors.primaryColor,
          //       focusColor: AppColors.primaryColor,
          //       activeColor: AppColors.primaryColor,
          //       fillColor: WidgetStateProperty.all(Colors.grey.shade300),
          //       value: context.read<SignupCubit>().isCheckboxChecked,
          //       onChanged: (bool? newValue) {
          //         setState(() {
          //           context.read<SignupCubit>().isCheckboxChecked =
          //               newValue ?? false; // Update the state
          //         });
          //       },
          //     ),
          //     Expanded(
          //       child: Text.rich(
          //         TextSpan(
          //           text: "signup.iAgreeToThe".tr(),
          //           style: TextStyles.textStyle11.copyWith(fontSize: 10),
          //           children: [
          //             TextSpan(
          //               text: "signup.termsOfServices".tr(),
          //               style: TextStyles.textStyle11.copyWith(
          //                 color: AppColors.primaryColor,
          //                 fontSize: 10,
          //                 fontWeight: FontWeight.bold,
          //                 decoration: TextDecoration.underline,
          //                 decorationColor: AppColors.primaryColor,
          //               ),
          //               recognizer: TapGestureRecognizer()
          //                 ..onTap = () {
          //                   // Navigate to Terms of Service page
          //                 },
          //             ),
          //             TextSpan(
          //               text: "signup.and".tr(),
          //               style: TextStyles.textStyle11.copyWith(fontSize: 10),
          //             ),
          //             TextSpan(
          //               text: "signup.privacyPolicy".tr(),
          //               style: TextStyles.textStyle11.copyWith(
          //                 fontSize: 10,
          //                 color: AppColors.primaryColor,
          //                 fontWeight: FontWeight.bold,
          //                 decoration: TextDecoration.underline,
          //                 decorationColor: AppColors.primaryColor,
          //               ),
          //               recognizer: TapGestureRecognizer()
          //                 ..onTap = () {
          //                   // Navigate to Privacy Policy page
          //                 },
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // Row(
          //   // crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Checkbox(
          //       side: BorderSide(color: Colors.transparent),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(3.r),
          //       ),
          //       checkColor: AppColors.primaryColor,
          //       focusColor: AppColors.primaryColor,
          //       activeColor: AppColors.primaryColor,
          //       fillColor: WidgetStateProperty.all(Colors.grey.shade300),
          //       value: context.read<SignupCubit>().isCheckboxChecked,
          //       onChanged: (bool? newValue) {
          //         setState(() {
          //           context.read<SignupCubit>().isCheckboxChecked =
          //               newValue ?? false; // Update the state
          //         });
          //       },
          //     ),
          //     Expanded(
          //       child: Text.rich(
          //         TextSpan(
          //           text: "signup.iAgreeToThe".tr(),
          //           style: TextStyles.textStyle11.copyWith(fontSize: 10),
          //           children: [
          //             TextSpan(
          //               text: "signup.termsOfServices".tr(),
          //               style: TextStyles.textStyle11.copyWith(
          //                 color: AppColors.primaryColor,
          //                 fontSize: 10,
          //                 fontWeight: FontWeight.bold,
          //                 decoration: TextDecoration.underline,
          //                 decorationColor: AppColors.primaryColor,
          //               ),
          //               recognizer: TapGestureRecognizer()
          //                 ..onTap = () {
          //                   // Navigate to Terms of Service page
          //                 },
          //             ),
          //             TextSpan(
          //               text: "signup.and".tr(),
          //               style: TextStyles.textStyle11.copyWith(fontSize: 10),
          //             ),
          //             TextSpan(
          //               text: "signup.privacyPolicy".tr(),
          //               style: TextStyles.textStyle11.copyWith(
          //                 fontSize: 10,
          //                 color: AppColors.primaryColor,
          //                 fontWeight: FontWeight.bold,
          //                 decoration: TextDecoration.underline,
          //                 decorationColor: AppColors.primaryColor,
          //               ),
          //               recognizer: TapGestureRecognizer()
          //                 ..onTap = () {
          //                   // Navigate to Privacy Policy page
          //                 },
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
