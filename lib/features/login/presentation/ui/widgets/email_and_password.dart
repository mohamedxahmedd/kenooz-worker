import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/helpers/app_regex.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/ui/widgets/forget_password.dart';



class EmailAndPasswordWidget extends StatefulWidget {
  const EmailAndPasswordWidget({super.key});

  @override
  State<EmailAndPasswordWidget> createState() => _EmailAndPasswordWidgetState();
}

class _EmailAndPasswordWidgetState extends State<EmailAndPasswordWidget> {
  bool isObsecure = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
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
    final loginCubit = context.read<LoginCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AutofillGroup(
        child: Form(
          key: loginCubit.formkey,
          child: Column(
            spacing: 2.sp,
            children: [
              CustomTextFormField(
                
                borderWidth: 0.5,
                borderColor: AppColors.lightBlueFillColor,
                
               // backgroundColor: AppColors.creamyColor,
                autofillHints: const [AutofillHints.username], // or email
                controller: loginCubit.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !AppRegex.isEmailValid(value)) {
                    return "signin.emailIsRequiredToLogin".tr();
                  }
                  return null;
                },
                labelText: "signin.email".tr(),
              ),
              CustomTextFormField(
                borderWidth: 0.5,
                borderColor: AppColors.lightBlueFillColor,
               // backgroundColor: AppColors.lightBlueFillColor,
                focusNode: _focusNode,
                autofillHints: const [AutofillHints.password],
                controller: loginCubit.passwordController,
                labelText: "signin.password".tr(),
                keyboardType: TextInputType.visiblePassword,
                obscureText: isObsecure,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "signin.passwordIsRequiredToLogIn".tr();
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
                      isObsecure ? Icons.visibility_off : Icons.visibility,
                    ),
                    color: (_isFocused)
                        ? AppColors.darkBrown
                        : AppColors.goldColor,
                  ),
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
