import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';

part 'silver_buy_create_carat_state.freezed.dart';

@freezed
class SilverBuyCreateCaratState with _$SilverBuyCreateCaratState {
  const factory SilverBuyCreateCaratState.initial() = _Initial;
  const factory SilverBuyCreateCaratState.loading() = Loading;
  const factory SilverBuyCreateCaratState.success(SilverCaratModel carat) = Success;
  const factory SilverBuyCreateCaratState.error({
    required List<String> messages,
  }) = Error;
}
