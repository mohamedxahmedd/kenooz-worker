import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_history_model.dart';

sealed class GoldSellHistoryState {
  const GoldSellHistoryState();

  const factory GoldSellHistoryState.initial() = GoldSellHistoryInitial;
  const factory GoldSellHistoryState.loading() = GoldSellHistoryLoading;
  const factory GoldSellHistoryState.success(
    List<GoldSellHistoryModel> sells,
  ) = GoldSellHistorySuccess;
  const factory GoldSellHistoryState.error(String message) =
      GoldSellHistoryError;
}

final class GoldSellHistoryInitial extends GoldSellHistoryState {
  const GoldSellHistoryInitial();
}

final class GoldSellHistoryLoading extends GoldSellHistoryState {
  const GoldSellHistoryLoading();
}

final class GoldSellHistorySuccess extends GoldSellHistoryState {
  final List<GoldSellHistoryModel> sells;
  const GoldSellHistorySuccess(this.sells);
}

final class GoldSellHistoryError extends GoldSellHistoryState {
  final String message;
  const GoldSellHistoryError(this.message);
}
