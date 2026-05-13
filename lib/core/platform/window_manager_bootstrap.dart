import 'package:flutter/widgets.dart';
import 'package:kenooz_worker_app/core/platform/app_platform.dart';
import 'package:window_manager/window_manager.dart';

/// Initializes the desktop window: sane minimum size, title, and centered on
/// first launch. No-op on mobile.
class WindowManagerBootstrap {
  WindowManagerBootstrap._();

  static const Size _minSize = Size(1280, 800);
  static const Size _initialSize = Size(1440, 900);
  static const String _title = 'Kenooz Worker';

  static Future<void> init() async {
    if (!AppPlatform.isDesktop) return;

    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size: _initialSize,
      minimumSize: _minSize,
      center: true,
      title: _title,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
