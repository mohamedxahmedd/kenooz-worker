import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_full_history_model.dart';

part 'gold_buy_history_state.freezed.dart';

@freezed
class GoldBuyHistoryState with _$GoldBuyHistoryState {
  const factory GoldBuyHistoryState.initial() = _Initial;
  const factory GoldBuyHistoryState.loading() = Loading;
  const factory GoldBuyHistoryState.success(
    List<GoldBuyFullHistoryModel> buys,
  ) = Success;
  const factory GoldBuyHistoryState.error(String message) = Error;
}
