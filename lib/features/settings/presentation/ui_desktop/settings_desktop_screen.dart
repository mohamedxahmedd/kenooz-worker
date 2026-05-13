import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/features/settings/presentation/ui/widgets/brightness_picker.dart';
import 'package:kenooz_worker_app/features/settings/presentation/ui/widgets/palette_picker.dart';
import 'package:kenooz_worker_app/features/settings/presentation/ui/widgets/theme_preview_card.dart';

/// Desktop settings panel. Two-column layout: section list on the left,
/// settings detail on the right. Reuses [BrightnessPicker], [PalettePicker],
/// and [ThemePreviewCard] from the mobile feature so palette / brightness
/// changes propagate through [SettingsCubit] without duplication.
class SettingsDesktopScreen extends StatelessWidget {
  const SettingsDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsStates>(
      buildWhen: (_, current) => current is ThemeChanged,
      builder: (context, _) {
        final cubit = SettingsCubit.get(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(title: 'settings.appearance'.tr()),
                const SizedBox(height: 12),
                DesktopCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ThemePreviewCard(),
                      const SizedBox(height: 20),
                      _Label(text: 'settings.appearance'.tr()),
                      const SizedBox(height: 8),
                      BrightnessPicker(
                        selected: cubit.brightness,
                        onChanged: cubit.changeBrightness,
                      ),
                      const SizedBox(height: 16),
                      _Label(text: 'settings.colorPalette'.tr()),
                      const SizedBox(height: 8),
                      PalettePicker(
                        selected: cubit.palette,
                        brightness: cubit.brightness,
                        onChanged: cubit.changePalette,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionHeader(title: 'settings.language'.tr()),
                const SizedBox(height: 12),
                DesktopCard(
                  padding: const EdgeInsets.all(20),
                  child: _LanguageRow(cubit: cubit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: AppFonts.heading(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: AppFonts.body(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.cubit});
  final SettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final current = context.locale.languageCode;
    return Row(
      children: [
        Expanded(
          child: _LangOption(
            label: 'settings.english'.tr(),
            selected: current == 'en',
            onTap: () => cubit.changeLanguage(
              context: context,
              lang: 'en',
              country: 'UK',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LangOption(
            label: 'settings.arabic'.tr(),
            selected: current == 'ar',
            onTap: () => cubit.changeLanguage(
              context: context,
              lang: 'ar',
              country: 'EG',
            ),
          ),
        ),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.10),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_rounded,
                  size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
