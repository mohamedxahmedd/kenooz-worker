import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_sell_history_model.dart';

sealed class SilverSellHistoryState {
  const SilverSellHistoryState();

  const factory SilverSellHistoryState.initial() = SilverSellHistoryInitial;
  const factory SilverSellHistoryState.loading() = SilverSellHistoryLoading;
  const factory SilverSellHistoryState.success(
    List<SilverSellHistoryModel> sells,
  ) = SilverSellHistorySuccess;
  const factory SilverSellHistoryState.error(String message) =
      SilverSellHistoryError;
}

final class SilverSellHistoryInitial extends SilverSellHistoryState {
  const SilverSellHistoryInitial();
}

final class SilverSellHistoryLoading extends SilverSellHistoryState {
  const SilverSellHistoryLoading();
}

final class SilverSellHistorySuccess extends SilverSellHistoryState {
  final List<SilverSellHistoryModel> sells;
  const SilverSellHistorySuccess(this.sells);
}

final class SilverSellHistoryError extends SilverSellHistoryState {
  final String message;
  const SilverSellHistoryError(this.message);
}
