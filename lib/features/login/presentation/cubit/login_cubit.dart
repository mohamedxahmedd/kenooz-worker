import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_request_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:kenooz_worker_app/features/login/data/repo/login_repo.dart';
import 'package:kenooz_worker_app/features/login/presentation/cubit/login_state.dart';



class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  LoginCubit(this._loginRepo) : super(const LoginState.initial());

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  Future<void> emitLoginStates() async {
    emit(const LoginState.loading());
    final response = await _loginRepo.login(
        loginReqModel: LoginRequestModel(
            email: emailController.text,
            password: passwordController.text,
            deviceName: 'apple',
            deviceToken:
                CacheHelper.getData(key: CacheKeys.fcmToken) ?? "test"));
    response.when(
      success: (loginResponse) async {
        await saveUserData(loginResponse);
        emit(LoginState.success(loginResponse));
      },
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(LoginState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(LoginState.error(messages: error.errorModel.messages));
        } else {
          emit(const LoginState.error(messages: ['Unknown error']));
        }
      },
    );
  }

  Future<void> saveUserData(LoginResponseModel loginResponse) async {
    try {
      await CacheHelper.setSecuredString(
          CacheKeys.userToken, loginResponse.accessToken);

      final savedToken =
          await CacheHelper.getSecuredString(CacheKeys.userToken);
      if (savedToken == loginResponse.accessToken) {
        isLoggedInUser = true;
        DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.accessToken);
      }

      await CacheHelper.saveData(
          key: CacheKeys.userId, value: loginResponse.user.id);
      await CacheHelper.saveData(
          key: CacheKeys.shopId, value: loginResponse.user.shopId);
      await CacheHelper.saveData(
          key: CacheKeys.userName, value: loginResponse.user.name);
      await CacheHelper.saveData(
          key: CacheKeys.userRole, value: loginResponse.user.role);
      await CacheHelper.saveData(
          key: CacheKeys.isAdmin, value: loginResponse.user.isAdmin == 1);

      // Schedule proactive token refresh (~5 min before expiry).
      TokenManager().scheduleProactiveRefresh(loginResponse.expiresIn);
    } catch (e) {
      // Handle the error appropriately
    }
  }
}
