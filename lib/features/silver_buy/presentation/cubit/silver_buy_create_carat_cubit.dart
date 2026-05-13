import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/create_silver_carat_request_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_create_carat_state.dart';

class SilverBuyCreateCaratCubit extends Cubit<SilverBuyCreateCaratState> {
  final SilverBuyRepo _repo;
  SilverBuyCreateCaratCubit(this._repo) : super(const SilverBuyCreateCaratState.initial());

  Future<void> createCarat(CreateSilverCaratRequestModel request) async {
    emit(const SilverBuyCreateCaratState.loading());
    final response = await _repo.createCarat(request);
    response.when(
      success: (carat) => emit(SilverBuyCreateCaratState.success(carat)),
      failure: (failure) => emit(SilverBuyCreateCaratState.error(messages: _extractMessages(failure.errorModel))),
    );
  }

  void resetState() {
    emit(const SilverBuyCreateCaratState.initial());
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
