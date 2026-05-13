import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_buy_preload_data.dart';

part 'silver_buy_preload_state.freezed.dart';

@freezed
class SilverBuyPreloadState with _$SilverBuyPreloadState {
  const factory SilverBuyPreloadState.initial() = _Initial;
  const factory SilverBuyPreloadState.loading() = Loading;
  const factory SilverBuyPreloadState.success(SilverBuyPreloadData data) = Success;
  const factory SilverBuyPreloadState.error({
    required List<String> messages,
  }) = Error;
}
