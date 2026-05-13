/// Sealed-class replacement for the previous Freezed `UpdateRatesState`.
sealed class UpdateRatesState<T> {
  const UpdateRatesState();

  const factory UpdateRatesState.initial() = Initial<T>;
  const factory UpdateRatesState.loading() = Loading<T>;
  const factory UpdateRatesState.success(T data) = Success<T>;
  const factory UpdateRatesState.error({required List<String> messages}) =
      Error<T>;
}

final class Initial<T> extends UpdateRatesState<T> {
  const Initial();
}

final class Loading<T> extends UpdateRatesState<T> {
  const Loading();
}

final class Success<T> extends UpdateRatesState<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends UpdateRatesState<T> {
  final List<String> messages;
  const Error({required this.messages});
}
