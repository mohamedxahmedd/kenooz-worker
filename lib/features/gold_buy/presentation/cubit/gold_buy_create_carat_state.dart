import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';

part 'gold_buy_create_carat_state.freezed.dart';

@freezed
class GoldBuyCreateCaratState with _$GoldBuyCreateCaratState {
  const factory GoldBuyCreateCaratState.initial() = _Initial;
  const factory GoldBuyCreateCaratState.loading() = Loading;
  const factory GoldBuyCreateCaratState.success(GoldCaratModel carat) = Success;
  const factory GoldBuyCreateCaratState.error({
    required List<String> messages,
  }) = Error;
}
