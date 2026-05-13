import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/delete_account/data/remote/delete_account_api_service.dart';

class DeleteAccountRepo {
  final DeleteAccountApiService _deleteAccountApiService;
  DeleteAccountRepo(this._deleteAccountApiService);

  Future<ApiResult<void>> deleteAccount() async {
    try {
      await _deleteAccountApiService.deleteAccount();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
