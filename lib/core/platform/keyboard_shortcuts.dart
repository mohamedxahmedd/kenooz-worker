import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/platform/app_platform.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';

/// App-wide keyboard shortcuts, wrapped around the desktop shell.
///
/// macOS uses the Cmd modifier, Windows/Linux use Ctrl. We bind both to the
/// same intents so the shell behaves natively on each platform.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.isDesktop) return child;

    final meta = AppPlatform.isMacOS;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.comma, meta: meta, control: !meta):
            const OpenSettingsIntent(),
        SingleActivator(LogicalKeyboardKey.keyN, meta: meta, control: !meta):
            const NewGoldSellIntent(),
        SingleActivator(LogicalKeyboardKey.keyB, meta: meta, control: !meta):
            const NewGoldBuyIntent(),
        SingleActivator(LogicalKeyboardKey.keyH, meta: meta, control: !meta):
            const GoHomeIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const CloseDialogIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
            onInvoke: (_) {
              navigatorKey.currentState
                  ?.pushNamed(Routes.settingsScreen);
              return null;
            },
          ),
          NewGoldSellIntent: CallbackAction<NewGoldSellIntent>(
            onInvoke: (_) {
              navigatorKey.currentState
                  ?.pushNamed(Routes.goldDoubleSellScreen);
              return null;
            },
          ),
          NewGoldBuyIntent: CallbackAction<NewGoldBuyIntent>(
            onInvoke: (_) {
              // Gold buy is launched from history; route through history.
              return null;
            },
          ),
          GoHomeIntent: CallbackAction<GoHomeIntent>(
            onInvoke: (_) {
              navigatorKey.currentState
                  ?.popUntil((route) => route.isFirst);
              return null;
            },
          ),
          CloseDialogIntent: CallbackAction<CloseDialogIntent>(
            onInvoke: (_) {
              final ctx = navigatorKey.currentContext;
              if (ctx == null) return null;
              final canPop = Navigator.of(ctx).canPop();
              if (canPop) Navigator.of(ctx).pop();
              return null;
            },
          ),
        },
        // We intentionally do NOT autofocus this Focus node. Autofocusing
        // here races the layout pass on macOS desktop and triggers
        // "Cannot hit test a render box that has never been laid out".
        child: Focus(child: child),
      ),
    );
  }
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class NewGoldSellIntent extends Intent {
  const NewGoldSellIntent();
}

class NewGoldBuyIntent extends Intent {
  const NewGoldBuyIntent();
}

class GoHomeIntent extends Intent {
  const GoHomeIntent();
}

class CloseDialogIntent extends Intent {
  const CloseDialogIntent();
}
