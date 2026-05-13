import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';

part 'silver_buy_client_search_state.freezed.dart';

@freezed
class SilverBuyClientSearchState with _$SilverBuyClientSearchState {
  const factory SilverBuyClientSearchState.initial() = _Initial;
  const factory SilverBuyClientSearchState.loading() = Loading;
  const factory SilverBuyClientSearchState.found(ClientModel client) = Found;
  const factory SilverBuyClientSearchState.notFound() = NotFound;
  const factory SilverBuyClientSearchState.created(ClientModel client) = Created;
  const factory SilverBuyClientSearchState.error({
    required List<String> messages,
  }) = Error;
}
