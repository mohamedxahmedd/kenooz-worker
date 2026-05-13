sealed class OngoingOrdersState<T> {
  const OngoingOrdersState();

  const factory OngoingOrdersState.initial() = OngoingOrdersInitial<T>;
  const factory OngoingOrdersState.loading() = OngoingOrdersLoading<T>;
  const factory OngoingOrdersState.success(T data) = OngoingOrdersSuccess<T>;
  const factory OngoingOrdersState.error({required List<String> messages}) =
      OngoingOrdersError<T>;
}

final class OngoingOrdersInitial<T> extends OngoingOrdersState<T> {
  const OngoingOrdersInitial();
}

final class OngoingOrdersLoading<T> extends OngoingOrdersState<T> {
  const OngoingOrdersLoading();
}

final class OngoingOrdersSuccess<T> extends OngoingOrdersState<T> {
  final T data;
  const OngoingOrdersSuccess(this.data);
}

final class OngoingOrdersError<T> extends OngoingOrdersState<T> {
  final List<String> messages;
  const OngoingOrdersError({required this.messages});
}
