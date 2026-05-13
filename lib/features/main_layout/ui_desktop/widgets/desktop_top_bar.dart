import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/app_brightness.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/settings_cubit.dart';

/// Top bar shown above the desktop content area. Hosts the screen title, a
/// theme toggle, a language toggle, and a profile/settings menu. Designed to
/// blend in with the surrounding desktop chrome.
class DesktopTopBar extends StatelessWidget {
  const DesktopTopBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.08);
    final branch = CacheHelper.getSavedBranch();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (branch != null) ...[
            _BranchChip(label: branch.name),
            const SizedBox(width: 8),
          ],
          const _ThemeToggleButton(),
          const SizedBox(width: 4),
          const _LanguageToggleButton(),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'menu.preferences'.tr(),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context)
                .pushNamed(Routes.settingsScreen),
          ),
        ],
      ),
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_outlined,
              size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsStates>(
      buildWhen: (p, c) => c is ThemeChanged,
      builder: (context, _) {
        final cubit = SettingsCubit.get(context);
        final isDark = cubit.isDark;
        return IconButton(
          tooltip: isDark
              ? 'settings.useLight'.tr()
              : 'settings.useDark'.tr(),
          icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: () => cubit.changeBrightness(
            isDark ? AppBrightness.light : AppBrightness.dark,
          ),
        );
      },
    );
  }
}

class _LanguageToggleButton extends StatelessWidget {
  const _LanguageToggleButton();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final cubit = SettingsCubit.get(context);
        final locale = context.locale.languageCode;
        final next = locale == 'ar'
            ? const _LangSpec('en', 'UK', 'EN')
            : const _LangSpec('ar', 'EG', 'AR');
        return TextButton(
          onPressed: () => cubit.changeLanguage(
            context: context,
            lang: next.lang,
            country: next.country,
          ),
          child: Text(next.display),
        );
      },
    );
  }
}

class _LangSpec {
  final String lang;
  final String country;
  final String display;
  const _LangSpec(this.lang, this.country, this.display);
}
