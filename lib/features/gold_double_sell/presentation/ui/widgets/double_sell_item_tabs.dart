import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class DoubleSellItemTabs extends StatefulWidget {
  final Widget insideTab;
  final Widget boxTab;
  final Widget outsideTab;

  const DoubleSellItemTabs({
    super.key,
    required this.insideTab,
    required this.boxTab,
    required this.outsideTab,
  });

  @override
  State<DoubleSellItemTabs> createState() => _DoubleSellItemTabsState();
}

class _DoubleSellItemTabsState extends State<DoubleSellItemTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_currentTabIndex == _tabController.index) return;
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  Widget _tabBody({required int index, required Widget child}) {
    final isVisible = _currentTabIndex == index;
    return Offstage(
      offstage: !isVisible,
      child: TickerMode(enabled: isVisible, child: child),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.goldColor.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(3.r),
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: isDark
                  ? AppColors.darkThemeContainerColorElevated
                  : AppColors.backGroundColorLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            labelStyle: AppFonts.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AppFonts.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            labelColor: isDark
                ? AppColors.lightTextColorForDarkMood
                : AppColors.darkBrown,
            unselectedLabelColor: isDark
                ? AppColors.textGreyColor
                : AppColors.darkGreyTextColor,
            tabs: [
              Tab(text: 'common.inside'.tr()),
              Tab(text: 'common.box'.tr()),
              Tab(text: 'common.outside'.tr()),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                _tabBody(index: 0, child: widget.insideTab),
                _tabBody(index: 1, child: widget.boxTab),
                _tabBody(index: 2, child: widget.outsideTab),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
