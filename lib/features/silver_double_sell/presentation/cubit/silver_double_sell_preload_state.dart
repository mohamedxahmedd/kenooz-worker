import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_double_sell_preload_data.dart';

part 'silver_double_sell_preload_state.freezed.dart';

@freezed
class SilverDoubleSellPreloadState with _$SilverDoubleSellPreloadState {
  const factory SilverDoubleSellPreloadState.initial() = _Initial;
  const factory SilverDoubleSellPreloadState.loading() = Loading;
  const factory SilverDoubleSellPreloadState.success(
    SilverDoubleSellPreloadData data,
  ) = Success;
  const factory SilverDoubleSellPreloadState.error({
    required List<String> messages,
  }) = Error;
}
