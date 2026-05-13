import 'package:flutter/material.dart';

/// Single entry in the desktop sidebar. Indices line up 1:1 with the
/// `_buildForIndex` switch in [DesktopContentHost], so reordering here also
/// reorders the rendered content.
class MainLayoutDrawerItem {
  const MainLayoutDrawerItem({
    required this.title,
    this.icon,
    this.svgPath,
  });

  /// Localization key for the rail label.
  final String title;

  /// Material icon used when [svgPath] is null.
  final IconData? icon;

  /// Optional SVG asset path (kept for parity with the legacy mobile drawer).
  final String? svgPath;
}

const List<MainLayoutDrawerItem> kMainLayoutDrawerItems = [
  MainLayoutDrawerItem(title: 'drawer.home', icon: Icons.home_outlined),
  MainLayoutDrawerItem(title: 'drawer.orders', icon: Icons.receipt_long_outlined),
  MainLayoutDrawerItem(title: 'drawer.goldMixSell', icon: Icons.workspace_premium_outlined),
  MainLayoutDrawerItem(title: 'drawer.diamondMixSell', icon: Icons.diamond_outlined),
  MainLayoutDrawerItem(title: 'drawer.silverMixSell', icon: Icons.shield_outlined),
  MainLayoutDrawerItem(title: 'drawer.goldBuy', icon: Icons.shopping_bag_outlined),
  MainLayoutDrawerItem(title: 'drawer.silverBuy', icon: Icons.shopping_basket_outlined),
  MainLayoutDrawerItem(title: 'drawer.goldHangings', icon: Icons.label_outline),
  MainLayoutDrawerItem(title: 'drawer.blogs', icon: Icons.article_outlined),
  MainLayoutDrawerItem(title: 'drawer.chats', icon: Icons.chat_bubble_outline),
  MainLayoutDrawerItem(title: 'drawer.profile', icon: Icons.person_outline),
];
