import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';

part 'gold_buy_client_search_state.freezed.dart';

@freezed
class GoldBuyClientSearchState with _$GoldBuyClientSearchState {
  const factory GoldBuyClientSearchState.initial() = _Initial;
  const factory GoldBuyClientSearchState.loading() = Loading;
  const factory GoldBuyClientSearchState.found(ClientModel client) = Found;
  const factory GoldBuyClientSearchState.notFound() = NotFound;
  const factory GoldBuyClientSearchState.created(ClientModel client) = Created;
  const factory GoldBuyClientSearchState.error({
    required List<String> messages,
  }) = Error;
}
