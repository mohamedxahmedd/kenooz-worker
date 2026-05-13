import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_full_history_model.dart';

part 'silver_buy_history_state.freezed.dart';

@freezed
class SilverBuyHistoryState with _$SilverBuyHistoryState {
  const factory SilverBuyHistoryState.initial() = _Initial;
  const factory SilverBuyHistoryState.loading() = Loading;
  const factory SilverBuyHistoryState.success(
    List<SilverBuyFullHistoryModel> buys,
  ) = Success;
  const factory SilverBuyHistoryState.error(String message) = Error;
}
