import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/client_sells_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/sell_find_model.dart';

part 'gold_buy_sell_link_state.freezed.dart';

@freezed
class GoldBuySellLinkState with _$GoldBuySellLinkState {
  const factory GoldBuySellLinkState.initial() = _Initial;
  const factory GoldBuySellLinkState.loading() = Loading;
  const factory GoldBuySellLinkState.foundSingle(SellFindModel sell) =
      FoundSingle;
  const factory GoldBuySellLinkState.foundClientSells(
    ClientSellsModel clientSells,
  ) = FoundClientSells;
  const factory GoldBuySellLinkState.notFound() = NotFound;
  const factory GoldBuySellLinkState.error({
    required List<String> messages,
  }) = Error;
}
