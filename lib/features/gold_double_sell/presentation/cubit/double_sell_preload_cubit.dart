import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_state.dart';

class DoubleSellPreloadCubit extends Cubit<DoubleSellPreloadState> {
  final GoldDoubleSellRepo _repo;

  DoubleSellPreloadCubit(this._repo)
    : super(const DoubleSellPreloadState.initial());

  Future<void> fetchPreloadData() async {
    emit(const DoubleSellPreloadState.loading());
    final response = await _repo.fetchPreloadData();

    response.when(
      success: (data) => emit(DoubleSellPreloadState.success(data)),
      failure: (failure) {
        emit(
          DoubleSellPreloadState.error(
            messages: _extractMessages(failure.errorModel),
          ),
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
