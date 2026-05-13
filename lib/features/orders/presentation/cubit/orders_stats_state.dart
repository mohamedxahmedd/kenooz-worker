sealed class OrdersStatsState<T> {
  const OrdersStatsState();

  const factory OrdersStatsState.initial() = OrdersStatsInitial<T>;
  const factory OrdersStatsState.loading() = OrdersStatsLoading<T>;
  const factory OrdersStatsState.success(T data) = OrdersStatsSuccess<T>;
  const factory OrdersStatsState.error({required List<String> messages}) =
      OrdersStatsError<T>;
}

final class OrdersStatsInitial<T> extends OrdersStatsState<T> {
  const OrdersStatsInitial();
}

final class OrdersStatsLoading<T> extends OrdersStatsState<T> {
  const OrdersStatsLoading();
}

final class OrdersStatsSuccess<T> extends OrdersStatsState<T> {
  final T data;
  const OrdersStatsSuccess(this.data);
}

final class OrdersStatsError<T> extends OrdersStatsState<T> {
  final List<String> messages;
  const OrdersStatsError({required this.messages});
}
