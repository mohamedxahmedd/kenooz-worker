import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/features/delete_account/data/repo/delete_account_repo.dart';
import 'package:kenooz_worker_app/features/delete_account/presentation/cubit/delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final DeleteAccountRepo _deleteAccountRepo;
  DeleteAccountCubit(this._deleteAccountRepo)
      : super(const DeleteAccountInitial());

  /// Calls the backend to delete the account, then wipes ALL local data
  /// so nothing remains on the device.
  Future<void> emitDeleteAccountStates() async {
    emit(const DeleteAccountLoading());

    final response = await _deleteAccountRepo.deleteAccount();
    response.when(
      success: (_) async {
        await _clearAllDataPermanently();
        emit(const DeleteAccountSuccess());
      },
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(DeleteAccountError(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(DeleteAccountError(messages: error.errorModel.messages));
        } else {
          emit(const DeleteAccountError(messages: ['Unknown error']));
        }
      },
    );
  }

  /// Permanently wipes everything: token, credentials, preferences.
  Future<void> _clearAllDataPermanently() async {
    try {
      TokenManager().cancelTimer();
      await CacheHelper.clearAllSecuredData();

      await CacheHelper.removeData(key: CacheKeys.userId);
      await CacheHelper.removeData(key: CacheKeys.shopId);
      await CacheHelper.removeData(key: CacheKeys.userName);
      await CacheHelper.removeData(key: CacheKeys.userRole);
      await CacheHelper.removeData(key: CacheKeys.isAdmin);
      await CacheHelper.removeData(key: CacheKeys.tokenExpiryTime);

      isLoggedInUser = false;
      DioFactory.setTokenIntoHeaderAfterLogin('');

      debugPrint('[DeleteAccount] All data cleared permanently');
    } catch (e) {
      debugPrint('[DeleteAccount] Error clearing data: $e');
    }
  }
}
