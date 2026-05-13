import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_product_model.dart';

part 'product_lookup_state.freezed.dart';

@freezed
class ProductLookupState with _$ProductLookupState {
  const factory ProductLookupState.initial() = _Initial;
  const factory ProductLookupState.loading() = Loading;
  const factory ProductLookupState.found(GoldProductModel product) = Found;
  const factory ProductLookupState.notFound() = NotFound;
  const factory ProductLookupState.alreadySold() = AlreadySold;
  const factory ProductLookupState.error({required List<String> messages}) =
      Error;
}
