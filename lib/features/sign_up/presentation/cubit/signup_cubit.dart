import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/sign_up/data/models/signup_request_model.dart';
import 'package:kenooz_worker_app/features/sign_up/data/repo/signup_repo.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_state.dart';



class SignupCubit extends Cubit<SignupStates> {
  final SignupRepo _signupRepo;
  SignupCubit(this._signupRepo) : super(const SignupStates.initial());

  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? gender;
  String? selectedType;
  bool isCheckboxChecked = false;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void emitSignupStates() async {
    emit(const SignupStates.loading());
    final response = await _signupRepo.signup(
        signupReqModel: SignupRequestModel(
            type: selectedType!,
            email: emailController.text,
            password: passwordController.text,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            phone: phoneController.text,
            birthday: birthdateController.text.isEmpty
                ? null
                : birthdateController.text,
            confirmPassword: confirmPasswordController.text,
            gender: gender));
    response.when(success: (signupResponse) {
      saveUserToken(signupResponse.token);

      emit(SignupStates.success(signupResponse));
    }, failure: (error) {
      if (error.errorModel is ListErrorModel) {
        final messages = (error.errorModel as ListErrorModel).messages;
        emit(SignupStates.error(messages: messages));
      } else if (error.errorModel is BaseErrorModel) {
        emit(SignupStates.error(
            messages: [error.errorModel.message ?? 'Unknown error']));
      } else {
        emit(const SignupStates.error(messages: ['Unknown error']));
      }
    });
  }

  void saveUserToken(token) async {
    await CacheHelper.setSecuredString(CacheKeys.userToken, token);
    isLoggedInUser = true;
    DioFactory.setTokenIntoHeaderAfterLogin(token);
  }
}
