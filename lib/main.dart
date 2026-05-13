import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/kenooz_worker.dart';
import 'package:kenooz_worker_app/core/bloc_observer.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/config/branches.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/functions/check_if_logged_in_user.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/core/platform/window_manager_bootstrap.dart';
import 'package:kenooz_worker_app/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WindowManagerBootstrap.init();
  await CacheHelper.init();
  await EasyLocalization.ensureInitialized();

  // ── Resolve branch BEFORE DI setup ──────────────────────────────────────
  final savedBranch = CacheHelper.getSavedBranch();
  final baseUrl = savedBranch?.baseUrl ?? Branches.defaultBranch.baseUrl;
  bool hasBranch = savedBranch != null;

  await setupGetIt(baseUrl: baseUrl);
  Bloc.observer = MyBlocObserver();
  await ScreenUtil.ensureScreenSize();
  await checkIfLoggedInUser();

  // If the user is already logged in, restore the proactive refresh timer.
  if (isLoggedInUser) {
    await TokenManager().restoreTimerIfNeeded();
  }

  // Migration: auto-assign default branch for existing logged-in users
  // so they skip the branch selection screen seamlessly.
  if (!hasBranch && isLoggedInUser) {
    await CacheHelper.saveBranch(Branches.defaultBranch);
    hasBranch = true;
  }

  runApp(
    EasyLocalization(
      saveLocale: true,
      useFallbackTranslations: true,
      fallbackLocale: const Locale('en', 'UK'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'UK')],
      path: 'assets/languages',
      child: KenoozWorker(appRouter: AppRouter(), hasBranch: hasBranch),
    ),
  );
}
//now prepear everything to generate .exe app to test it on windows laptop (prepear app icon, app name , ...etc ) then generate the app 