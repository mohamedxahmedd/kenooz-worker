import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/repo/silver_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_double_sell_preload_state.dart';

class SilverDoubleSellPreloadCubit extends Cubit<SilverDoubleSellPreloadState> {
  final SilverDoubleSellRepo _repo;

  SilverDoubleSellPreloadCubit(this._repo)
    : super(const SilverDoubleSellPreloadState.initial());

  Future<void> fetchPreloadData() async {
    emit(const SilverDoubleSellPreloadState.loading());
    final response = await _repo.fetchPreloadData();

    response.when(
      success: (data) => emit(SilverDoubleSellPreloadState.success(data)),
      failure: (failure) {
        emit(
          SilverDoubleSellPreloadState.error(
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
