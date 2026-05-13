import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/app_regex.dart';
import 'package:kenooz_worker_app/core/helpers/spacing.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:kenooz_worker_app/core/theming/text_styles.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_cubit.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/ui/widgets/gender_birthdate_widget.dart';


class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({
    super.key,
  });

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  bool isObsecure = true;
  bool isConfirmpassObsecure = true;
  bool _isFocused = false;
  bool _isConfirmPassFocused = false;
  late FocusNode _focusNode;
  late FocusNode _focusConfrimPassNode;
  final List<String> _usersTypes = ['client'.tr(), 'guardian'.tr()];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusConfrimPassNode = FocusNode();
    _focusConfrimPassNode.addListener(() {
      setState(() {
        _isConfirmPassFocused = _focusConfrimPassNode.hasFocus;
      });
    });
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Form(
        key: context.read<SignupCubit>().formkey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 0.43.sw,
                  child: CustomTextFormField(
                    borderWidth: 0.5,
                    borderColor: AppColors.lightBlueFillColor,
                    backgroundColor: AppColors.lightBlueFillColor,
                    autofillHints: const [AutofillHints.name],
                    controller: context.read<SignupCubit>().firstNameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "signup.firstNameIsRequiredToSignUp".tr();
                      }
                      return null;
                    },
                    labelText: "signup.firstName".tr(),
                  ),
                ),
                SizedBox(
                  width: 0.43.sw,
                  child: CustomTextFormField(
                    borderWidth: 0.5,
                    borderColor: AppColors.lightBlueFillColor,
                    backgroundColor: AppColors.lightBlueFillColor,
                    autofillHints: const [AutofillHints.name],
                    controller: context.read<SignupCubit>().lastNameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "signup.lastNameIsRequiredToSignUp".tr();
                      }
                      return null;
                    },
                    labelText: "signup.lastName".tr(),
                  ),
                ),
              ],
            ),
            CustomTextFormField(
              borderWidth: 0.5,
              borderColor: AppColors.lightBlueFillColor,
              backgroundColor: AppColors.lightBlueFillColor,
              autofillHints: const [AutofillHints.email],
              controller: context.read<SignupCubit>().emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty || !AppRegex.isEmailValid(value)) {
                  return "signup.emailIsRequiredToSignUp".tr();
                }
                return null;
              },
              labelText: "signup.email".tr(),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    validator: (value) {
                      if (value == null) {
                        return "IsRequiredToSignUp".tr();
                      }
                      return null;
                    },
                    dropdownColor: (context.read<SettingsCubit>().isDark)
                        ? AppColors.bottomNavDarkThemeBackground
                        : Colors.white,
                    value: _selectedType,
                    items: _usersTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyles.textStyle14.copyWith(),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(
                          color: AppColors
                              .errorColor, // ← same or another error color
                          width: 1.5,
                        ),
                      ),

                      // 3) border when the field has an error and is focused:
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(
                          color: AppColors
                              .errorColor, // ← same or another error color
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors
                          .transparent, // Background color of the dropdown
                      labelText: 'signup.type'.tr(),
                      labelStyle: TextStyles.textStyle14.copyWith(
                          color: (_selectedType != null)
                              ? AppColors.primaryColor
                              : Colors.grey.shade700,
                          fontWeight:
                              (_selectedType != null) ? FontWeight.bold : null,
                          fontSize: (_selectedType != null) ? 13.sp : 13.sp),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.r), // Add border radius
                        borderSide: BorderSide(
                          color: Colors
                              .white, // Optional: Add a focus border color
                          width: 0.5,
                        ), // Remove the border line
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.r), // Add border radius
                        borderSide: BorderSide(
                          color: Colors
                              .white, // Optional: Add a focus border color
                          width: 0.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.r), // Add border radius
                        borderSide: BorderSide(
                          color: Colors
                              .white, // Optional: Add a focus border color
                          width: 0.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 10.w,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == null) {
                          _selectedType = "signup.type".tr();
                        }
                        _selectedType = value;
                        if (value == "client".tr()) {
                          context.read<SignupCubit>().selectedType = "Client";
                        } else {
                          context.read<SignupCubit>().selectedType = "Guardian";
                        }
                      });
                    },
                  ),
                ),
                horizontalSpace(10.w),
                Expanded(
                  flex: 3,
                  child: CustomTextFormField(
                    borderWidth: 0.5,
                    borderColor: AppColors.lightBlueFillColor,
                    backgroundColor: AppColors.lightBlueFillColor,
                    autofillHints: const [AutofillHints.email],
                    controller: context.read<SignupCubit>().phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty ||
                          !AppRegex.isPhoneNumberValid(value)) {
                        return "signup.phoneIsRequiredToSignUp".tr();
                      }
                      return null;
                    },
                    labelText: "signup.phone".tr(),
                  ),
                ),
              ],
            ),
            CustomTextFormField(
              borderWidth: 0.5,
              borderColor: AppColors.lightBlueFillColor,
              backgroundColor: AppColors.lightBlueFillColor,
              foucseNode: _focusNode,
              autofillHints: const [AutofillHints.password],
              controller: context.read<SignupCubit>().passwordController,
              labelText: "signup.password".tr(),
              keyboardType: TextInputType.visiblePassword,
              obscureText: isObsecure,
              validator: (value) {
                if (value!.isEmpty) {
                  return "signup.passwordIsRequiredToSignUp".tr();
                }
                if (value.length <= 6) {
                  return "signup.passwordShouldBeAtLeast6Characters".tr();
                }
                if (value !=
                    context
                        .read<SignupCubit>()
                        .confirmPasswordController
                        .text) {
                  return "signup.passwordsDoNotMatch".tr();
                }
                return null;
              },
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isObsecure = !isObsecure;
                    });
                  },
                  icon: Icon(
                      isObsecure ? Icons.visibility_off : Icons.visibility),
                  color: (_isFocused)
                      ? AppColors.primaryColor
                      : Colors.grey.shade500,
                ),
              ),
            ),
            CustomTextFormField(
              borderWidth: 0.5,
              borderColor: AppColors.lightBlueFillColor,
              backgroundColor: AppColors.lightBlueFillColor,
              foucseNode: _focusConfrimPassNode,
              autofillHints: const [AutofillHints.password],
              controller: context.read<SignupCubit>().confirmPasswordController,
              labelText: "signup.confirmPassword".tr(),
              keyboardType: TextInputType.visiblePassword,
              obscureText: isConfirmpassObsecure,
              validator: (value) {
                if (value!.isEmpty) {
                  return "signup.confirmPasswordIsRequiredToSignUp".tr();
                }
                if (value.length <= 6) {
                  return "signup.passwordShouldBeAtLeast6Characters".tr();
                }
                if (value !=
                    context.read<SignupCubit>().passwordController.text) {
                  return "signup.passwordsDoNotMatch".tr();
                }
                return null;
              },
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isConfirmpassObsecure = !isConfirmpassObsecure;
                    });
                  },
                  icon: Icon(isConfirmpassObsecure
                      ? Icons.visibility_off
                      : Icons.visibility),
                  color: (_isConfirmPassFocused)
                      ? AppColors.primaryColor
                      : Colors.grey.shade500,
                ),
              ),
            ),
            GenderAndBirthdateForm(),
          ],
        ),
      ),
    );
  }
}
