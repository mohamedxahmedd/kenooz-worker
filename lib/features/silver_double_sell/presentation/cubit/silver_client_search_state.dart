import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';

part 'silver_client_search_state.freezed.dart';

@freezed
class SilverClientSearchState with _$SilverClientSearchState {
  const factory SilverClientSearchState.initial() = _Initial;
  const factory SilverClientSearchState.loading() = Loading;
  const factory SilverClientSearchState.found(ClientModel client) = Found;
  const factory SilverClientSearchState.notFound() = NotFound;
  const factory SilverClientSearchState.created(ClientModel client) = Created;
  const factory SilverClientSearchState.error({required List<String> messages}) = Error;
}
