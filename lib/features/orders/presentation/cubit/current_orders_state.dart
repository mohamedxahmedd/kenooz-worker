/// Sealed-class replacement for the previous Freezed `CurrentOrdersState`.
/// Subclasses are prefixed so the file can be imported alongside other
/// orders state files without `Loading`/`Success`/`Error` collisions.
sealed class CurrentOrdersState<T> {
  const CurrentOrdersState();

  const factory CurrentOrdersState.initial() = CurrentOrdersInitial<T>;
  const factory CurrentOrdersState.loading() = CurrentOrdersLoading<T>;
  const factory CurrentOrdersState.success(T data) = CurrentOrdersSuccess<T>;
  const factory CurrentOrdersState.error({required List<String> messages}) =
      CurrentOrdersError<T>;
}

final class CurrentOrdersInitial<T> extends CurrentOrdersState<T> {
  const CurrentOrdersInitial();
}

final class CurrentOrdersLoading<T> extends CurrentOrdersState<T> {
  const CurrentOrdersLoading();
}

final class CurrentOrdersSuccess<T> extends CurrentOrdersState<T> {
  final T data;
  const CurrentOrdersSuccess(this.data);
}

final class CurrentOrdersError<T> extends CurrentOrdersState<T> {
  final List<String> messages;
  const CurrentOrdersError({required this.messages});
}
