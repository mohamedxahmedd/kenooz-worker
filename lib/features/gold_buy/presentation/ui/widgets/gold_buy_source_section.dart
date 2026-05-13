import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class GoldBuySourceSection extends StatefulWidget {
  final Widget clientTab;
  final Widget vendorTab;
  final ValueChanged<int>? onTabChanged; // 0 = client, 1 = vendor

  const GoldBuySourceSection({
    super.key,
    required this.clientTab,
    required this.vendorTab,
    this.onTabChanged,
  });

  @override
  State<GoldBuySourceSection> createState() => _GoldBuySourceSectionState();
}

class _GoldBuySourceSectionState extends State<GoldBuySourceSection> {
  int _selectedIndex = 0; // 0 = client, 1 = vendor

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented tab bar
        _SourceTabBar(
          selectedIndex: _selectedIndex,
          isDark: isDark,
          onTap: (index) {
            if (index == _selectedIndex) return;
            setState(() => _selectedIndex = index);
            widget.onTabChanged?.call(index);
          },
        ),
        SizedBox(height: 12.h),
        // Active tab content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SizeTransition(
                sizeFactor: curved,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _selectedIndex == 0 ? widget.clientTab : widget.vendorTab,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SourceTabBar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _SourceTabBar({
    required this.selectedIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final shellColor = isDark
        ? AppColors.darkThemeContainerColorElevated
        : const Color(0xFFF4EEE8);
    final shellBorderColor = isDark
        ? Colors.white.withOpacity(0.09)
        : AppColors.darkBrown.withOpacity(0.13);

    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        color: shellColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: shellBorderColor),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: AppColors.darkBrown.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: _selectedAlignment(isRtl),
                  child: Container(
                    width: constraints.maxWidth / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                AppColors.darkBrown.withOpacity(0.95),
                                AppColors.goldColor.withOpacity(0.85),
                              ]
                            : [AppColors.darkBrown, AppColors.goldColor],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.08 : 0.42),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withOpacity(0.24),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    _TabItem(
                      index: 0,
                      label: 'common.client'.tr(),
                      icon: Icons.person_rounded,
                      isSelected: selectedIndex == 0,
                      isDark: isDark,
                      onTap: onTap,
                    ),
                    _TabItem(
                      index: 1,
                      label: 'common.vendor'.tr(),
                      icon: Icons.storefront_rounded,
                      isSelected: selectedIndex == 1,
                      isDark: isDark,
                      onTap: onTap,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Alignment _selectedAlignment(bool isRtl) {
    if (selectedIndex == 0) {
      return isRtl ? Alignment.centerRight : Alignment.centerLeft;
    }
    return isRtl ? Alignment.centerLeft : Alignment.centerRight;
  }
}

class _TabItem extends StatelessWidget {
  final int index;
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFg = Colors.white;
    final unselectedFg = isDark
        ? AppColors.lightTextColorForDarkMood.withOpacity(0.82)
        : AppColors.darkGreyTextColor;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => onTap(index),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(isDark ? 0.16 : 0.22)
                            : isDark
                            ? Colors.white.withOpacity(0.06)
                            : AppColors.darkBrown.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 14.sp,
                        color: isSelected ? selectedFg : unselectedFg,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      label,
                      style: AppFonts.body(
                        fontSize: 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isSelected ? selectedFg : unselectedFg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
