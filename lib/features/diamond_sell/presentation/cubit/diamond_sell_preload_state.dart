import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_preload_data.dart';

part 'diamond_sell_preload_state.freezed.dart';

@freezed
class DiamondSellPreloadState with _$DiamondSellPreloadState {
  const factory DiamondSellPreloadState.initial() = _Initial;
  const factory DiamondSellPreloadState.loading() = Loading;
  const factory DiamondSellPreloadState.success(
    DiamondSellPreloadData data,
  ) = Success;
  const factory DiamondSellPreloadState.error({
    required List<String> messages,
  }) = Error;
}
