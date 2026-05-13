import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/platform/keyboard_shortcuts.dart';
import 'package:kenooz_worker_app/core/platform/platform_menu_bar.dart';
import 'package:kenooz_worker_app/features/main_layout/cubit/main_layout_cubit.dart';
import 'package:kenooz_worker_app/features/main_layout/ui_desktop/main_layout_drawer_items.dart';
import 'package:kenooz_worker_app/features/main_layout/ui_desktop/widgets/desktop_content_host.dart';
import 'package:kenooz_worker_app/features/main_layout/ui_desktop/widgets/desktop_sidebar_nav.dart';
import 'package:kenooz_worker_app/features/main_layout/ui_desktop/widgets/desktop_top_bar.dart';

/// Permanent-sidebar shell used as the post-login root on desktop. Reuses the
/// existing `MainLayoutCubit` index contract so feature screens behave the
/// same on both shells.
class MainLayoutDesktopScreen extends StatefulWidget {
  const MainLayoutDesktopScreen({super.key});

  @override
  State<MainLayoutDesktopScreen> createState() =>
      _MainLayoutDesktopScreenState();
}

class _MainLayoutDesktopScreenState extends State<MainLayoutDesktopScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainLayoutCubit, MainLayoutState>(
      builder: (context, _) {
        // Keep the global mobile-mirror index in sync so legacy code paths
        // that read `mainLayoutIntitalScreenIndex` continue to work.
        mainLayoutIntitalScreenIndex = _selectedIndex == 0 ? 0 : 0;

        final title = _titleForIndex(_selectedIndex);

        return AppPlatformMenuBar(
          child: AppShortcuts(
            child: Scaffold(
              body: Row(
                children: [
                  DesktopSidebarNav(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      if (index == _selectedIndex) return;
                      setState(() => _selectedIndex = index);
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        DesktopTopBar(title: title),
                        Expanded(
                          child: DesktopContentHost(index: _selectedIndex),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _titleForIndex(int index) {
    if (index >= 0 && index < kMainLayoutDrawerItems.length) {
      return kMainLayoutDrawerItems[index].title.tr();
    }
    return '';
  }
}
