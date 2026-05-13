import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/config/branch_model.dart';
import 'package:kenooz_worker_app/core/config/branches.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';

/// Desktop branch picker. Centered card with side-by-side branch tiles and a
/// single Continue button. Calls the same persistence + DI reset path as the
/// mobile screen so the rest of the app behaves identically.
class BranchSelectionDesktopScreen extends StatefulWidget {
  const BranchSelectionDesktopScreen({super.key});

  @override
  State<BranchSelectionDesktopScreen> createState() =>
      _BranchSelectionDesktopScreenState();
}

class _BranchSelectionDesktopScreenState
    extends State<BranchSelectionDesktopScreen> {
  BranchModel? _selected;
  bool _busy = false;

  Future<void> _onContinue() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() => _busy = true);
    try {
      await CacheHelper.saveBranch(selected);
      await resetServicesForBranch(selected.baseUrl);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.loginScreen,
        (_) => false,
      );
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DesktopCard(
              padding: const EdgeInsets.symmetric(
                  vertical: 40, horizontal: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        Assets.assetsImagesLogo,
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'branch.selectBranch'.tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.heading(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'branch.selectDescription'.tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.body(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      for (var i = 0; i < Branches.all.length; i++) ...[
                        Expanded(
                          child: _BranchTile(
                            branch: Branches.all[i],
                            selected: _selected == Branches.all[i],
                            onTap: () =>
                                setState(() => _selected = Branches.all[i]),
                          ),
                        ),
                        if (i != Branches.all.length - 1)
                          const SizedBox(width: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:
                        (_selected != null && !_busy) ? _onContinue : null,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'branch.continue'.tr(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({
    required this.branch,
    required this.selected,
    required this.onTap,
  });

  final BranchModel branch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.10)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? accent
                : theme.colorScheme.onSurface.withValues(alpha: 0.10),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: 0.10),
              child: ClipOval(
                child: Image.asset(
                  Assets.assetsImagesLogo,
                  width: 28,
                  height: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                branch.name,
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? accent
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
