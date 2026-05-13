import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_result_model.dart';

part 'diamond_sell_submit_state.freezed.dart';

@freezed
class DiamondSellSubmitState with _$DiamondSellSubmitState {
  const factory DiamondSellSubmitState.initial() = _Initial;
  const factory DiamondSellSubmitState.loading() = Loading;
  const factory DiamondSellSubmitState.success(
    DiamondSellResultModel data,
  ) = Success;
  const factory DiamondSellSubmitState.error({
    required List<String> messages,
  }) = Error;
}
