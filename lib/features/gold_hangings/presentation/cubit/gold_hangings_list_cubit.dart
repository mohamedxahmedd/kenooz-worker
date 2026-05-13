import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/repo/gold_hangings_repo.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_list_state.dart';

class GoldHangingsListCubit extends Cubit<GoldHangingsListState> {
  final GoldHangingsRepo _repo;
  GoldHangingsListCubit(this._repo)
      : super(const GoldHangingsListState.initial());

  Future<void> fetchHanged() async {
    emit(const GoldHangingsListState.loading());
    final response = await _repo.fetchHangedList();
    response.when(
      success: (items) => emit(GoldHangingsListState.success(items)),
      failure: (failure) => emit(
        GoldHangingsListState.error(_extractMessage(failure.errorModel)),
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
