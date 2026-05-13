import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/platform/app_platform.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';

/// Wraps the desktop shell in a native menu bar on macOS. On other platforms
/// the menu is a no-op (Windows native menus are added later if needed).
class AppPlatformMenuBar extends StatelessWidget {
  const AppPlatformMenuBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.isMacOS) return child;

    final meta = const SingleActivator(LogicalKeyboardKey.comma, meta: true);
    final newSell = const SingleActivator(LogicalKeyboardKey.keyN, meta: true);
    final goHome = const SingleActivator(LogicalKeyboardKey.keyH, meta: true);

    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: 'menu.app'.tr(),
          menus: <PlatformMenuItem>[
            PlatformMenuItem(
              label: 'menu.preferences'.tr(),
              shortcut: meta,
              onSelected: () => navigatorKey.currentState
                  ?.pushNamed(Routes.settingsScreen),
            ),
            const PlatformMenuItemGroup(
              members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit)],
            ),
          ],
        ),
        PlatformMenu(
          label: 'menu.file'.tr(),
          menus: <PlatformMenuItem>[
            PlatformMenuItem(
              label: 'menu.newGoldSell'.tr(),
              shortcut: newSell,
              onSelected: () => navigatorKey.currentState
                  ?.pushNamed(Routes.goldDoubleSellScreen),
            ),
          ],
        ),
        PlatformMenu(
          label: 'menu.view'.tr(),
          menus: <PlatformMenuItem>[
            PlatformMenuItem(
              label: 'menu.home'.tr(),
              shortcut: goHome,
              onSelected: () => navigatorKey.currentState
                  ?.popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
