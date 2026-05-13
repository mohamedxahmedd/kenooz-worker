sealed class PastOrdersState<T> {
  const PastOrdersState();

  const factory PastOrdersState.initial() = PastOrdersInitial<T>;
  const factory PastOrdersState.loading() = PastOrdersLoading<T>;
  const factory PastOrdersState.success(T data) = PastOrdersSuccess<T>;
  const factory PastOrdersState.error({required List<String> messages}) =
      PastOrdersError<T>;
}

final class PastOrdersInitial<T> extends PastOrdersState<T> {
  const PastOrdersInitial();
}

final class PastOrdersLoading<T> extends PastOrdersState<T> {
  const PastOrdersLoading();
}

final class PastOrdersSuccess<T> extends PastOrdersState<T> {
  final T data;
  const PastOrdersSuccess(this.data);
}

final class PastOrdersError<T> extends PastOrdersState<T> {
  final List<String> messages;
  const PastOrdersError({required this.messages});
}
