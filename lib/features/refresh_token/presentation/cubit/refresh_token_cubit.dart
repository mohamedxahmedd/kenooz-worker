import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:kenooz_worker_app/features/refresh_token/data/repo/refresh_token_repo.dart';
import 'package:kenooz_worker_app/features/refresh_token/presentation/cubit/refresh_token_state.dart';

class RefreshTokenCubit extends Cubit<RefreshTokenState> {
  final RefreshTokenRepo _refreshTokenRepo;
  RefreshTokenCubit(this._refreshTokenRepo)
      : super(const RefreshTokenState.initial());

  Future<void> emitRefreshTokenStates() async {
    emit(const RefreshTokenState.loading());
    final response = await _refreshTokenRepo.refreshToken();
    response.when(
      success: (loginResponse) async {
        await saveNewToken(loginResponse);
        emit(RefreshTokenState.success(loginResponse));
      },
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(RefreshTokenState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(RefreshTokenState.error(messages: error.errorModel.messages));
        } else {
          emit(const RefreshTokenState.error(messages: ['Unknown error']));
        }
      },
    );
  }

  Future<void> saveNewToken(LoginResponseModel loginResponse) async {
    try {
      await CacheHelper.setSecuredString(
          CacheKeys.userToken, loginResponse.accessToken);
      DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.accessToken);

      // Schedule proactive token refresh (~5 min before expiry).
      TokenManager().scheduleProactiveRefresh(loginResponse.expiresIn);
    } catch (e) {
      // Handle error appropriately
    }
  }
}
