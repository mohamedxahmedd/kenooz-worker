/// Sealed-class replacement for the previous Freezed `HomeState`. Factories
/// keep the emit-site API; subclass names preserve `state is X` checks and
/// pattern-matching switches.
sealed class HomeState<T> {
  const HomeState();

  const factory HomeState.initial() = Initial<T>;
  const factory HomeState.loading() = Loading<T>;
  const factory HomeState.success(T data) = Success<T>;
  const factory HomeState.error({required List<String> messages}) = Error<T>;
}

final class Initial<T> extends HomeState<T> {
  const Initial();
}

final class Loading<T> extends HomeState<T> {
  const Loading();
}

final class Success<T> extends HomeState<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends HomeState<T> {
  final List<String> messages;
  const Error({required this.messages});
}
