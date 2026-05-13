import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/routing/app_router.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:kenooz_worker_app/core/theming/themes.dart';

class KenoozWorker extends StatelessWidget {
  const KenoozWorker({
    super.key,
    required this.appRouter,
    required this.hasBranch,
  });
  final AppRouter appRouter;
  final bool hasBranch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit()..hydrateFromCache(),
      child: BlocConsumer<SettingsCubit, SettingsStates>(
        listener: (context, state) {},
        // Only rebuild for theme changes — EasyLocalization handles locale
        // rebuilds internally via context.locale, so we must NOT rebuild
        // the MaterialApp for LocalizationLoading/LocalizationChange states
        // (doing so races with EasyLocalization and overrides the new locale).
        buildWhen: (previous, current) => current is ThemeChanged,
        builder: (context, state) {
          final cubit = SettingsCubit.get(context);
          final app = MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: buildAppTheme(
              palette: cubit.palette,
              brightness: cubit.brightness,
            ),
            title: 'Kenooz Worker',
            onGenerateRoute: appRouter.generateRoute,
            initialRoute: hasBranch
                ? Routes.mainlayoutScreen
                : Routes.branchSelectionScreen,
            builder: EasyLoading.init(),
          );
          // Shared widgets still use `.w/.h/.sp/.r` extensions; ScreenUtilInit
          // is initialized with a desktop design size so they render at sane
          // values without the cost of rewriting every callsite.
          return ScreenUtilInit(
            minTextAdapt: false,
            designSize: const Size(1280, 800),
            child: app,
          );
        },
      ),
    );
  }
}
