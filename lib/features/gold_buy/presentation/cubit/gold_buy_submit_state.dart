import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_response_model.dart';

part 'gold_buy_submit_state.freezed.dart';

@freezed
class GoldBuySubmitState with _$GoldBuySubmitState {
  const factory GoldBuySubmitState.initial() = _Initial;
  const factory GoldBuySubmitState.loading() = Loading;
  const factory GoldBuySubmitState.success(GoldBuyResponseModel data) = Success;
  const factory GoldBuySubmitState.error({
    required List<String> messages,
  }) = Error;
}
