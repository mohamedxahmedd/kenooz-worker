import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_state.dart';

class DiamondSellPreloadCubit extends Cubit<DiamondSellPreloadState> {
  final DiamondSellRepo _repo;

  DiamondSellPreloadCubit(this._repo)
    : super(const DiamondSellPreloadState.initial());

  Future<void> fetchPreloadData() async {
    emit(const DiamondSellPreloadState.loading());
    final response = await _repo.fetchPreloadData();

    response.when(
      success: (data) => emit(DiamondSellPreloadState.success(data)),
      failure: (failure) {
        emit(
          DiamondSellPreloadState.error(
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
