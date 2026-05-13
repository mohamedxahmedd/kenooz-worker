import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_client_sells_model.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/models/silver_sell_find_model.dart';

part 'silver_buy_sell_link_state.freezed.dart';

@freezed
class SilverBuySellLinkState with _$SilverBuySellLinkState {
  const factory SilverBuySellLinkState.initial() = _Initial;
  const factory SilverBuySellLinkState.loading() = Loading;
  const factory SilverBuySellLinkState.foundSingle(SilverSellFindModel sell) =
      FoundSingle;
  const factory SilverBuySellLinkState.foundClientSells(
    SilverClientSellsModel clientSells,
  ) = FoundClientSells;
  const factory SilverBuySellLinkState.notFound() = NotFound;
  const factory SilverBuySellLinkState.error({
    required List<String> messages,
  }) = Error;
}
