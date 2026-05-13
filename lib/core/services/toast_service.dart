import 'package:flutter/material.dart';
import 'package:kenooz_worker_app/core/constant.dart';

/// Cross-app toast/snackbar. Dispatches a floating Material [SnackBar] via the
/// root [navigatorKey] so callers don't need a [BuildContext].
class ToastService {
  ToastService._();

  static void show(
    String message, {
    Color background = Colors.black87,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: textColor)),
          backgroundColor: background,
          duration: duration,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
