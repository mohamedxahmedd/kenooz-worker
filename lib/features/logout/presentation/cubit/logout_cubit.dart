import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/features/logout/data/repo/logout_repo.dart';
import 'package:kenooz_worker_app/features/logout/presentation/cubit/logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutRepo _logoutRepo;
  LogoutCubit(this._logoutRepo) : super(const LogoutState.initial());

  Future<void> emitLogoutStates() async {
    emit(const LogoutState.loading());
    final response = await _logoutRepo.logout();
    response.when(
      success: (logoutResponse) async {
        await clearUserData();
        emit(LogoutState.success(logoutResponse));
      },
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(LogoutState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(LogoutState.error(messages: error.errorModel.messages));
        } else {
          emit(const LogoutState.error(messages: ['Unknown error']));
        }
      },
    );
  }

  /// Clears auth data but PRESERVES biometric credentials (email/password)
  /// so the user can still use biometric login after logging out.
  Future<void> clearUserData() async {
    try {
      // Cancel the proactive refresh timer first.
      TokenManager().cancelTimer();

      // Only remove the token — keep biometric credentials intact.
      await CacheHelper.clearAuthDataPreservingBiometric();

      await CacheHelper.removeData(key: CacheKeys.shopId);
      await CacheHelper.removeData(key: CacheKeys.userName);
      await CacheHelper.removeData(key: CacheKeys.userRole);
      await CacheHelper.removeData(key: CacheKeys.tokenExpiryTime);
      isLoggedInUser = false;
      DioFactory.setTokenIntoHeaderAfterLogin('');
    } catch (e) {
      // Handle error appropriately
    }
  }

  /// Clears ALL user data INCLUDING biometric credentials.
  /// Used exclusively when the account is permanently deleted.
  Future<void> clearAllDataIncludingBiometric() async {
    try {
      TokenManager().cancelTimer();

      // Wipe everything from secure storage (token + biometric credentials).
      await CacheHelper.clearAllSecuredData();

      // Also disable the biometric preference flag.
      await CacheHelper.saveData(key: 'biometric_enabled', value: false);

      await CacheHelper.removeData(key: CacheKeys.userId);
      await CacheHelper.removeData(key: CacheKeys.shopId);
      await CacheHelper.removeData(key: CacheKeys.userName);
      await CacheHelper.removeData(key: CacheKeys.userRole);
      await CacheHelper.removeData(key: CacheKeys.isAdmin);
      await CacheHelper.removeData(key: CacheKeys.tokenExpiryTime);
      isLoggedInUser = false;
      DioFactory.setTokenIntoHeaderAfterLogin('');
    } catch (e) {
      // Handle error appropriately
    }
  }
}
