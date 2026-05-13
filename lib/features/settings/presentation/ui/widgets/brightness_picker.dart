import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_brightness.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/themes.dart';

class BrightnessPicker extends StatelessWidget {
  final AppBrightness selected;
  final ValueChanged<AppBrightness> onChanged;

  const BrightnessPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final mode in AppBrightness.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _BrightnessTile(
                mode: mode,
                isSelected: mode == selected,
                onTap: () => onChanged(mode),
              ),
            ),
          ),
      ],
    );
  }
}

class _BrightnessTile extends StatelessWidget {
  final AppBrightness mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _BrightnessTile({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (mode) {
      case AppBrightness.light:
        return 'settings.light'.tr();
      case AppBrightness.dark:
        return 'settings.dark'.tr();
      case AppBrightness.deepDark:
        return 'settings.deepDark'.tr();
    }
  }

  IconData get _icon {
    switch (mode) {
      case AppBrightness.light:
        return Icons.light_mode_rounded;
      case AppBrightness.dark:
        return Icons.dark_mode_rounded;
      case AppBrightness.deepDark:
        return Icons.bedtime_rounded;
    }
  }

  Color _previewBg() {
    switch (mode) {
      case AppBrightness.light:
        return const Color(0xFFFDF7EF);
      case AppBrightness.dark:
        return const Color(0xFF1C2B24);
      case AppBrightness.deepDark:
        return const Color(0xFF000000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = tokensOf(context);
    final previewBg = _previewBg();
    final previewFg = mode == AppBrightness.light
        ? const Color(0xFF1A1A1A)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: previewBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? tokens.primary
                  : tokens.divider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: tokens.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 28.sp, color: previewFg),
              SizedBox(height: 8.h),
              Text(
                _label,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: previewFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
