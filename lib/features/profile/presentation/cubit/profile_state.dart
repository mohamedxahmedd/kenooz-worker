/// Sealed-class replacement for the previous Freezed `ProfileState`.
sealed class ProfileState<T> {
  const ProfileState();

  const factory ProfileState.initial() = Initial<T>;
  const factory ProfileState.loading() = Loading<T>;
  const factory ProfileState.success(T data) = Success<T>;
  const factory ProfileState.error({required List<String> messages}) = Error<T>;
}

final class Initial<T> extends ProfileState<T> {
  const Initial();
}

final class Loading<T> extends ProfileState<T> {
  const Loading();
}

final class Success<T> extends ProfileState<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends ProfileState<T> {
  final List<String> messages;
  const Error({required this.messages});
}
