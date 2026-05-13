import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/routing/args/chat_conversation_args.dart';
import 'package:kenooz_worker_app/features/branch_selection/presentation/ui_desktop/branch_selection_desktop_screen.dart';
import 'package:kenooz_worker_app/features/chat/presentation/cubit/chat_conversation_cubit.dart';
import 'package:kenooz_worker_app/features/chat/presentation/ui/chat_conversation_screen.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui_desktop/diamond_sell_desktop_screen.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/client_search_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_kinds_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui_desktop/gold_double_sell_desktop_screen.dart';
import 'package:kenooz_worker_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:kenooz_worker_app/features/login/presentation/ui_desktop/login_desktop_screen.dart';
import 'package:kenooz_worker_app/features/main_layout/cubit/main_layout_cubit.dart';
import 'package:kenooz_worker_app/features/main_layout/ui_desktop/main_layout_desktop_screen.dart';
import 'package:kenooz_worker_app/features/settings/presentation/ui_desktop/settings_desktop_screen.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_cubit.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/ui_desktop/sign_up_desktop_screen.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_create_vendor_cubit.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_double_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_double_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/cubit/silver_product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/presentation/ui_desktop/silver_double_sell_desktop_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => SignupCubit(getIt()),
            child: const SignUpDesktopScreen(),
          ),
        );

      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginCubit(getIt()),
            child: const LoginDesktopScreen(),
          ),
        );

      case Routes.mainlayoutScreen:
      case Routes.desktopMainLayoutScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => MainLayoutCubit(),
            child: const MainLayoutDesktopScreen(),
          ),
        );

      case Routes.branchSelectionScreen:
        return MaterialPageRoute(
          builder: (_) => const BranchSelectionDesktopScreen(),
        );

      case Routes.settingsScreen:
        return MaterialPageRoute(
          builder: (_) => const SettingsDesktopScreen(),
        );

      case Routes.goldDoubleSellScreen:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => DoubleSellPreloadCubit(getIt())),
              BlocProvider(create: (_) => ClientSearchCubit(getIt())),
              BlocProvider(create: (_) => ProductLookupCubit(getIt())),
              BlocProvider(create: (_) => GoldKindsCubit(getIt())),
              BlocProvider(create: (_) => DoubleSellSubmitCubit(getIt())),
              BlocProvider(create: (_) => CreateVendorCubit(getIt())),
            ],
            child: const GoldDoubleSellDesktopScreen(),
          ),
        );

      case Routes.diamondSellScreen:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => DiamondSellPreloadCubit(getIt())),
              BlocProvider(create: (_) => DiamondClientSearchCubit(getIt())),
              BlocProvider(create: (_) => DiamondProductLookupCubit(getIt())),
              BlocProvider(create: (_) => DiamondSellSubmitCubit(getIt())),
            ],
            child: const DiamondSellDesktopScreen(),
          ),
        );

      case Routes.silverDoubleSellScreen:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SilverDoubleSellPreloadCubit(getIt())),
              BlocProvider(create: (_) => SilverClientSearchCubit(getIt())),
              BlocProvider(create: (_) => SilverProductLookupCubit(getIt())),
              BlocProvider(create: (_) => SilverDoubleSellSubmitCubit(getIt())),
              BlocProvider(create: (_) => SilverCreateVendorCubit(getIt())),
            ],
            child: const SilverDoubleSellDesktopScreen(),
          ),
        );

      case Routes.chatConversationScreen:
        final args = settings.arguments as ChatConversationArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatConversationCubit(getIt()),
            child: ChatConversationScreen(args: args),
          ),
        );

      default:
        return null;
    }
  }
}
