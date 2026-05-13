import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/unhang_request_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/repo/gold_hangings_repo.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_unhang_state.dart';

class GoldHangingsUnhangCubit extends Cubit<GoldHangingsUnhangState> {
  final GoldHangingsRepo _repo;
  GoldHangingsUnhangCubit(this._repo)
      : super(const GoldHangingsUnhangState.initial());

  Future<void> unhang(int goldId) async {
    emit(GoldHangingsUnhangState.loading(goldId));
    final response = await _repo.unhangGold(UnhangRequestModel(goldId: goldId));
    response.when(
      success: (data) => emit(GoldHangingsUnhangState.success(data)),
      failure: (failure) => emit(
        GoldHangingsUnhangState.error(
          messages: _extractMessages(failure.errorModel),
        ),
      ),
    );
  }

  void reset() => emit(const GoldHangingsUnhangState.initial());

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) {
      return [errorModel.message ?? 'An unexpected error occurred'];
    }
    return ['An unexpected error occurred'];
  }
}
