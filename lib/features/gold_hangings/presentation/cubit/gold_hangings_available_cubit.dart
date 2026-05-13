import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/repo/gold_hangings_repo.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_available_state.dart';

class GoldHangingsAvailableCubit extends Cubit<GoldHangingsAvailableState> {
  final GoldHangingsRepo _repo;
  GoldHangingsAvailableCubit(this._repo)
      : super(const GoldHangingsAvailableState.initial());

  Future<void> fetchAvailable() async {
    emit(const GoldHangingsAvailableState.loading());
    final response = await _repo.fetchAvailableList();
    response.when(
      success: (items) => emit(GoldHangingsAvailableState.success(items)),
      failure: (failure) => emit(
        GoldHangingsAvailableState.error(_extractMessage(failure.errorModel)),
      ),
    );
  }

  String _extractMessage(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages.first;
    if (errorModel is BaseErrorModel) {
      return errorModel.message ?? 'An unexpected error occurred';
    }
    return 'An unexpected error occurred';
  }
}
