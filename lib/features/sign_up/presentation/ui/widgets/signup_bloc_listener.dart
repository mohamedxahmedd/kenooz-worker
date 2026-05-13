// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_top_snack_bar.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_cubit.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_state.dart';


class SignupBlocListener extends StatelessWidget {
  const SignupBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupStates>(
      listenWhen: (previous, current) =>
          current is Loading || current is Success || current is Error,
      listener: (context, state) {
        switch (state) {
          case Loading():
            EasyLoading.show();
          case Success():
            Future.delayed(const Duration(seconds: 1), () {
              EasyLoading.dismiss();
              successSnackBar(
                msg: "signup.signupSuccess".tr(),
                context: context,
              );
              context.pushNamedAndRemoveUntil(
                Routes.loginScreen,
                (route) => false,
                predicate: (Route<dynamic> route) {
                  return false;
                },
              );
            });
          case Error(:final messages):
            EasyLoading.dismiss();
            failureSnackBar(msg: messages.join('\n'), context: context);
          case Initial():
            break;
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
