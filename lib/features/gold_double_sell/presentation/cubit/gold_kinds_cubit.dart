import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_kinds_state.dart';

class GoldKindsCubit extends Cubit<GoldKindsState> {
  final GoldDoubleSellRepo _repo;

  GoldKindsCubit(this._repo) : super(const GoldKindsState.initial());

  Future<void> fetchKinds(int caratId) async {
    if (caratId <= 0) {
      emit(const GoldKindsState.initial());
      return;
    }

    emit(const GoldKindsState.loading());

    final response = await _repo.fetchKindsByCarat(caratId);
    response.when(
      success: (kinds) => emit(GoldKindsState.success(kinds)),
      failure: (failure) {
        emit(
          GoldKindsState.error(messages: _extractMessages(failure.errorModel)),
        );
      },
    );
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) {
      return errorModel.messages;
    }
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
