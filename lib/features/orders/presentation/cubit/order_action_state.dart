sealed class OrderActionState<T> {
  const OrderActionState();

  const factory OrderActionState.initial() = OrderActionInitial<T>;
  const factory OrderActionState.loading() = OrderActionLoading<T>;
  const factory OrderActionState.success(T data) = OrderActionSuccess<T>;
  const factory OrderActionState.error({required List<String> messages}) =
      OrderActionError<T>;
}

final class OrderActionInitial<T> extends OrderActionState<T> {
  const OrderActionInitial();
}

final class OrderActionLoading<T> extends OrderActionState<T> {
  const OrderActionLoading();
}

final class OrderActionSuccess<T> extends OrderActionState<T> {
  final T data;
  const OrderActionSuccess(this.data);
}

final class OrderActionError<T> extends OrderActionState<T> {
  final List<String> messages;
  const OrderActionError({required this.messages});
}
