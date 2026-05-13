import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/profile/data/models/update_profile_request_model.dart';
import 'package:kenooz_worker_app/features/profile/data/repo/profile_repo.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final ProfileRepo _profileRepo;
  EditProfileCubit(this._profileRepo) : super(const EditProfileInitial());

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    emit(const EditProfileLoading());
    final request = UpdateProfileRequestModel(
      name: name,
      phone: phone,
      email: email,
    );
    final response = await _profileRepo.updateProfile(request);
    response.when(
      success: (_) => emit(
        const EditProfileSuccess(message: 'Profile updated successfully'),
      ),
      failure: (error) => emit(EditProfileError(messages: _extractErrors(error))),
    );
  }

  Future<void> updateProfileImage(String filePath) async {
    emit(const EditProfileImageLoading());
    final response = await _profileRepo.saveProfileImage(filePath);
    response.when(
      success: (profile) => emit(
        EditProfileImageSuccess(imageUrl: profile.image),
      ),
      failure: (error) => emit(EditProfileError(messages: _extractErrors(error))),
    );
  }

  List<String> _extractErrors(dynamic error) {
    if (error.errorModel is BaseErrorModel) {
      return [error.errorModel.message ?? 'Unknown error'];
    } else if (error.errorModel is ListErrorModel) {
      return error.errorModel.messages;
    }
    return ['Unknown error'];
  }
}
