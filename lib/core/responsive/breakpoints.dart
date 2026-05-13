import 'package:flutter/widgets.dart';

/// Material 3-style window size classes used to switch between mobile, tablet,
/// and full desktop layouts.
enum WindowSize { compact, medium, expanded }

class Breakpoints {
  Breakpoints._();

  static const double mediumMin = 600;
  static const double expandedMin = 1200;

  static WindowSize sizeOf(BuildContext context) =>
      sizeFromWidth(MediaQuery.sizeOf(context).width);

  static WindowSize sizeFromWidth(double width) {
    if (width >= expandedMin) return WindowSize.expanded;
    if (width >= mediumMin) return WindowSize.medium;
    return WindowSize.compact;
  }
}

extension WindowSizeX on WindowSize {
  bool get isCompact => this == WindowSize.compact;
  bool get isMedium => this == WindowSize.medium;
  bool get isExpanded => this == WindowSize.expanded;
  bool get isDesktopClass => this == WindowSize.medium || this == WindowSize.expanded;
}
