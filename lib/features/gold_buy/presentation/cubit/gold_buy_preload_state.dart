import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_preload_data.dart';

part 'gold_buy_preload_state.freezed.dart';

@freezed
class GoldBuyPreloadState with _$GoldBuyPreloadState {
  const factory GoldBuyPreloadState.initial() = _Initial;
  const factory GoldBuyPreloadState.loading() = Loading;
  const factory GoldBuyPreloadState.success(GoldBuyPreloadData data) = Success;
  const factory GoldBuyPreloadState.error({
    required List<String> messages,
  }) = Error;
}
