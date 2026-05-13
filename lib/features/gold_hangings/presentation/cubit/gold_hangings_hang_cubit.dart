import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hang_request_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/repo/gold_hangings_repo.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_hang_state.dart';

class GoldHangingsHangCubit extends Cubit<GoldHangingsHangState> {
  final GoldHangingsRepo _repo;
  GoldHangingsHangCubit(this._repo)
      : super(const GoldHangingsHangState.initial());

  Future<void> hangGolds(HangRequestModel request) async {
    emit(const GoldHangingsHangState.loading());
    final response = await _repo.hangGolds(request);
    response.when(
      success: (data) => emit(GoldHangingsHangState.success(data)),
      failure: (failure) => emit(
        GoldHangingsHangState.error(
          messages: _extractMessages(failure.errorModel),
        ),
      ),
    );
  }

  void reset() => emit(const GoldHangingsHangState.initial());

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
