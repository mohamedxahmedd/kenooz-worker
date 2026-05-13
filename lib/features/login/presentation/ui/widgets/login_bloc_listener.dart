// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_top_snack_bar.dart';
import 'package:kenooz_worker_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:kenooz_worker_app/features/login/presentation/cubit/login_state.dart';

class LoginBlocListener extends StatelessWidget {
  const LoginBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          current is Loading || current is Error || current is Success,
      listener: (context, state) {
        switch (state) {
          case Loading():
            EasyLoading.show();
          case Error(:final messages):
            EasyLoading.dismiss();
            failureSnackBar(msg: messages[0], context: context);
          case Success():
            TextInput.finishAutofillContext();
            Future.delayed(const Duration(seconds: 1), () {
              EasyLoading.dismiss();
              successSnackBar(
                msg: "signin.loginSuccess".tr(),
                context: context,
              );

              mainLayoutIntitalScreenIndex = 0;
              context.pushNamedAndRemoveUntil(
                Routes.mainlayoutScreen,
                (route) => false,
                predicate: (Route<dynamic> route) {
                  return false;
                },
              );
            });
          case Initial():
            break;
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
