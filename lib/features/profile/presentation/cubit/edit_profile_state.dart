sealed class EditProfileState {
  const EditProfileState();
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileSuccess extends EditProfileState {
  final String message;
  const EditProfileSuccess({required this.message});
}

class EditProfileImageLoading extends EditProfileState {
  const EditProfileImageLoading();
}

class EditProfileImageSuccess extends EditProfileState {
  final String? imageUrl;
  const EditProfileImageSuccess({required this.imageUrl});
}

class EditProfileError extends EditProfileState {
  final List<String> messages;
  const EditProfileError({required this.messages});
}
