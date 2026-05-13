import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/constant.dart';

part 'main_layout_state.dart';

class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(const MainLayoutInitial());

  static MainLayoutCubit get(context) => BlocProvider.of(context);

  int _previousIndex = 0;

  void changeBottomNavBar(int index) {
    _previousIndex = mainLayoutIntitalScreenIndex;
    mainLayoutIntitalScreenIndex = index;
    emit(AppBottomNavState(mainLayoutIntitalScreenIndex, _previousIndex));
  }
}
