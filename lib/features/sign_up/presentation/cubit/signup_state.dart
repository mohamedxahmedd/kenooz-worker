/// Sealed-class replacement for the previous Freezed `SignupStates`.
/// Factory constructors preserve the existing emit-site API; subclass names
/// (`Initial`, `Loading`, `Success`, `Error`) keep the existing `state is X`
/// checks and pattern-matching switches working.
sealed class SignupStates<T> {
  const SignupStates();

  const factory SignupStates.initial() = Initial<T>;
  const factory SignupStates.loading() = Loading<T>;
  const factory SignupStates.success(T data) = Success<T>;
  const factory SignupStates.error({required List<String> messages}) = Error<T>;
}

final class Initial<T> extends SignupStates<T> {
  const Initial();
}

final class Loading<T> extends SignupStates<T> {
  const Loading();
}

final class Success<T> extends SignupStates<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends SignupStates<T> {
  final List<String> messages;
  const Error({required this.messages});
}
