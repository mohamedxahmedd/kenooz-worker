import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_sell_link_state.dart';

class SilverBuySellLinkCubit extends Cubit<SilverBuySellLinkState> {
  final SilverBuyRepo _repo;
  SilverBuySellLinkCubit(this._repo) : super(const SilverBuySellLinkState.initial());

  Future<void> findByOrderId(int id) async {
    emit(const SilverBuySellLinkState.loading());
    final response = await _repo.findSellById(id);
    response.when(
      success: (sell) => emit(SilverBuySellLinkState.foundSingle(sell)),
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const SilverBuySellLinkState.notFound());
        } else {
          emit(SilverBuySellLinkState.error(messages: _extractMessages(failure.errorModel)));
        }
      },
    );
  }

  Future<void> findByClient(String term) async {
    emit(const SilverBuySellLinkState.loading());
    final response = await _repo.findSellsByClient(term);
    response.when(
      success: (clientSells) => emit(SilverBuySellLinkState.foundClientSells(clientSells)),
      failure: (failure) {
        if (_isNotFound(failure.errorModel)) {
          emit(const SilverBuySellLinkState.notFound());
        } else {
          emit(SilverBuySellLinkState.error(messages: _extractMessages(failure.errorModel)));
        }
      },
    );
  }

  void clearLink() {
    emit(const SilverBuySellLinkState.initial());
  }

  bool _isNotFound(dynamic errorModel) {
    if (errorModel is BaseErrorModel) {
      return errorModel.message?.toLowerCase().contains('not found') ?? false;
    }
    if (errorModel is ListErrorModel) {
      return errorModel.messages.any((m) => m.toLowerCase().contains('not found'));
    }
    return false;
  }

  List<String> _extractMessages(dynamic errorModel) {
    if (errorModel is ListErrorModel) return errorModel.messages;
    if (errorModel is BaseErrorModel) return [errorModel.message ?? 'An unexpected error occurred'];
    return ['An unexpected error occurred'];
  }
}
