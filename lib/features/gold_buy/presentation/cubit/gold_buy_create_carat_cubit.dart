import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/create_carat_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/repo/gold_buy_repo.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_create_carat_state.dart';

class GoldBuyCreateCaratCubit extends Cubit<GoldBuyCreateCaratState> {
  final GoldBuyRepo _repo;
  GoldBuyCreateCaratCubit(this._repo) : super(const GoldBuyCreateCaratState.initial());

  Future<void> createCarat(CreateCaratRequestModel request) async {
    emit(const GoldBuyCreateCaratState.loading());
    final response = await _repo.createCarat(request);
    response.when(
      success: (carat) => emit(GoldBuyCreateCaratState.success(carat)),
      failure: (failure) => emit(GoldBuyCreateCaratState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  void resetState() {
    emit(const GoldBuyCreateCaratState.initial());
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
