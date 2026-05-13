import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_preload_data.dart';

part 'double_sell_preload_state.freezed.dart';

@freezed
class DoubleSellPreloadState with _$DoubleSellPreloadState {
  const factory DoubleSellPreloadState.initial() = _Initial;
  const factory DoubleSellPreloadState.loading() = Loading;
  const factory DoubleSellPreloadState.success(DoubleSellPreloadData data) =
      Success;
  const factory DoubleSellPreloadState.error({required List<String> messages}) =
      Error;
}
