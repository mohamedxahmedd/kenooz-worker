part of 'main_layout_cubit.dart';

sealed class MainLayoutState extends Equatable {
  const MainLayoutState();

  @override
  List<Object> get props => const [];
}

final class MainLayoutInitial extends MainLayoutState {
  const MainLayoutInitial();
}

final class AppBottomNavState extends MainLayoutState {
  final int currentIndex;
  final int previousIndex;

  const AppBottomNavState(this.currentIndex, [this.previousIndex = 0]);

  @override
  List<Object> get props => [currentIndex, previousIndex];
}

final class GoToNotificationState extends MainLayoutState {
  const GoToNotificationState();
}

final class DrawerItemSelectedState extends MainLayoutState {
  final int drawerIndex;
  const DrawerItemSelectedState(this.drawerIndex);

  @override
  List<Object> get props => [drawerIndex];
}
