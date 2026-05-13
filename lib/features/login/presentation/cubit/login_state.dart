/// Sealed-class replacement for the previous Freezed `LoginState`.
/// The named factories preserve the existing emit-site API
/// (`LoginState.initial()`, `.loading()`, `.success(data)`, `.error(messages:)`)
/// while subclass names (`Initial`, `Loading`, `Success`, `Error`) keep the
/// existing `state is X` checks and pattern-matching switches working.
sealed class LoginState<T> {
  const LoginState();

  const factory LoginState.initial() = Initial<T>;
  const factory LoginState.loading() = Loading<T>;
  const factory LoginState.success(T data) = Success<T>;
  const factory LoginState.error({required List<String> messages}) = Error<T>;
}

final class Initial<T> extends LoginState<T> {
  const Initial();
}

final class Loading<T> extends LoginState<T> {
  const Loading();
}

final class Success<T> extends LoginState<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends LoginState<T> {
  final List<String> messages;
  const Error({required this.messages});
}
