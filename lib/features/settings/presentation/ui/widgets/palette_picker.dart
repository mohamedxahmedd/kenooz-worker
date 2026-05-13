import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_brightness.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/app_palette.dart';
import 'package:kenooz_worker_app/core/theming/palette_resolver.dart';
import 'package:kenooz_worker_app/core/theming/themes.dart';

class PalettePicker extends StatelessWidget {
  final AppPalette selected;
  final AppBrightness brightness;
  final ValueChanged<AppPalette> onChanged;

  const PalettePicker({
    super.key,
    required this.selected,
    required this.brightness,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.6,
      children: [
        for (final p in AppPalette.values)
          _PaletteTile(
            palette: p,
            brightness: brightness,
            isSelected: p == selected,
            onTap: () => onChanged(p),
          ),
      ],
    );
  }
}

class _PaletteTile extends StatelessWidget {
  final AppPalette palette;
  final AppBrightness brightness;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.brightness,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (palette) {
      case AppPalette.gold:
        return 'settings.paletteGold'.tr();
      case AppPalette.silver:
        return 'settings.paletteSilver'.tr();
      case AppPalette.diamond:
        return 'settings.paletteDiamond'.tr();
      case AppPalette.red:
        return 'settings.paletteRed'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = resolvePalette(palette, brightness);
    final activeBorder = tokensOf(context).primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: preview.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? activeBorder : preview.divider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeBorder.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _swatch(preview.primary),
                  SizedBox(width: 6.w),
                  _swatch(preview.secondary),
                  SizedBox(width: 6.w),
                  _swatch(preview.surfaceElevated),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20.sp,
                      color: activeBorder,
                    ),
                ],
              ),
              Text(
                _label,
                style: AppFonts.heading(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: preview.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
      ),
    );
  }
}
