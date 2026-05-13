import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/home/data/repo/home_repo.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  HomeCubit(this._homeRepo) : super(const HomeState.initial());

  Future<void> fetchAllRates() async {
    emit(const HomeState.loading());
    final response = await _homeRepo.fetchAllRates();
    response.when(
      success: (homeData) => emit(HomeState.success(homeData)),
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(HomeState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(HomeState.error(messages: error.errorModel.messages));
        } else {
          emit(const HomeState.error(messages: ['Unknown error']));
        }
      },
    );
  }
}
