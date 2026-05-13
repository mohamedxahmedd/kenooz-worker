import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_delete_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blogs_list_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/ui_desktop/blogs_desktop_screen.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_history_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_inbox_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui_desktop/chat_desktop_screen.dart';
import 'package:kenooz_worker_app/features/delete_account/presentation/cubit/delete_account_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_history_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui_desktop/diamond_sell_history_desktop_screen.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_history_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/gold_buy_history_screen.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_sell_history_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui_desktop/gold_sell_history_desktop_screen.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_list_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_unhang_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/ui_desktop/gold_hangings_desktop_screen.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/update_rates_cubit.dart';
import 'package:kenooz_worker_app/features/home/presentation/ui/home_screen.dart';
import 'package:kenooz_worker_app/features/logout/presentation/cubit/logout_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/current_orders_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/ongoing_orders_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/order_action_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/orders_stats_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/past_orders_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/ui_desktop/orders_desktop_screen.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/profile_screen.dart';
import 'package:kenooz_worker_app/features/refresh_token/presentation/cubit/refresh_token_cubit.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/cubit/silver_buy_history_cubit.dart';
import 'package:kenooz_worker_app/features/silver_buy/presentation/ui/silver_buy_history_screen.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_sell_history_cubit.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/ui_desktop/silver_sell_history_desktop_screen.dart';

/// Resolves a sidebar index to the matching feature screen, providing the
/// required Cubits. Mirrors the index contract from
/// `kMainLayoutDrawerItems` and the mobile drawer-feature switch so screens
/// stay identical on both shells (Phase 1).
class DesktopContentHost extends StatelessWidget {
  const DesktopContentHost({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    // Force a fresh subtree (and cubits) every time the user switches tabs;
    // matches the mobile drawer's behaviour.
    return KeyedSubtree(
      key: ValueKey('desktop-content-$index'),
      child: _buildForIndex(index),
    );
  }

  Widget _buildForIndex(int index) {
    switch (index) {
      case 0:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => HomeCubit(getIt())),
            BlocProvider(create: (_) => UpdateRatesCubit(getIt())),
          ],
          child: const HomeScreen(),
        );
      case 1:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CurrentOrdersCubit(getIt())),
            BlocProvider(create: (_) => OngoingOrdersCubit(getIt())),
            BlocProvider(create: (_) => PastOrdersCubit(getIt())),
            BlocProvider(create: (_) => OrderActionCubit(getIt())),
            BlocProvider(create: (_) => OrdersStatsCubit(getIt())),
          ],
          child: const OrdersDesktopScreen(),
        );
      case 2:
        return BlocProvider(
          create: (_) => GoldSellHistoryCubit(getIt()),
          child: const GoldSellHistoryDesktopScreen(),
        );
      case 3:
        return BlocProvider(
          create: (_) => DiamondSellHistoryCubit(getIt()),
          child: const DiamondSellHistoryDesktopScreen(),
        );
      case 4:
        return BlocProvider(
          create: (_) => SilverSellHistoryCubit(getIt()),
          child: const SilverSellHistoryDesktopScreen(),
        );
      case 5:
        return BlocProvider(
          create: (_) => GoldBuyHistoryCubit(getIt()),
          child: const GoldBuyHistoryScreen(),
        );
      case 6:
        return BlocProvider(
          create: (_) => SilverBuyHistoryCubit(getIt()),
          child: const SilverBuyHistoryScreen(),
        );
      case 7:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => GoldHangingsListCubit(getIt())),
            BlocProvider(create: (_) => GoldHangingsUnhangCubit(getIt())),
          ],
          child: const GoldHangingsDesktopScreen(),
        );
      case 8:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => BlogsListCubit(getIt())),
            BlocProvider(create: (_) => BlogDeleteCubit(getIt())),
          ],
          child: const BlogsDesktopScreen(),
        );
      case 9:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ChatInboxCubit(getIt())),
            BlocProvider(create: (_) => ChatHistoryCubit(getIt())),
          ],
          child: const ChatDesktopScreen(),
        );
      case 10:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProfileCubit(getIt())),
            BlocProvider(create: (_) => LogoutCubit(getIt())),
            BlocProvider(create: (_) => DeleteAccountCubit(getIt())),
            BlocProvider(create: (_) => RefreshTokenCubit(getIt())),
          ],
          child: const ProfileScreen(),
        );
      default:
        return Center(child: Text('common.notFound'.tr()));
    }
  }
}
