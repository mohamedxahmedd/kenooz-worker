import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_unified_sell_history_model.dart';

sealed class DiamondSellHistoryState {
  const DiamondSellHistoryState();

  const factory DiamondSellHistoryState.initial() = DiamondSellHistoryInitial;
  const factory DiamondSellHistoryState.loading() = DiamondSellHistoryLoading;
  const factory DiamondSellHistoryState.success(
    List<DiamondUnifiedSellHistoryModel> sells,
  ) = DiamondSellHistorySuccess;
  const factory DiamondSellHistoryState.error(String message) =
      DiamondSellHistoryError;
}

final class DiamondSellHistoryInitial extends DiamondSellHistoryState {
  const DiamondSellHistoryInitial();
}

final class DiamondSellHistoryLoading extends DiamondSellHistoryState {
  const DiamondSellHistoryLoading();
}

final class DiamondSellHistorySuccess extends DiamondSellHistoryState {
  final List<DiamondUnifiedSellHistoryModel> sells;
  const DiamondSellHistorySuccess(this.sells);
}

final class DiamondSellHistoryError extends DiamondSellHistoryState {
  final String message;
  const DiamondSellHistoryError(this.message);
}
