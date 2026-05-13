import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/profile/data/repo/profile_repo.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;
  ProfileCubit(this._profileRepo) : super(const ProfileState.initial());

  Future<void> getProfile() async {
    emit(const ProfileState.loading());
    final response = await _profileRepo.getProfile();
    response.when(
      success: (profile) => emit(ProfileState.success(profile)),
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(ProfileState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(ProfileState.error(messages: error.errorModel.messages));
        } else {
          emit(const ProfileState.error(messages: ['Unknown error']));
        }
      },
    );
  }
}
