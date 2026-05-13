import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/cached_image_widget.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hanged_gold_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_available_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_hang_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_list_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_list_state.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_unhang_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_unhang_state.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/ui/gold_hangings_picker_screen.dart';

const Color _accent = Color(0xFFCBA135);

/// Desktop Gold Hangings — two-pane view: searchable list on the left, full
/// detail + unhang action on the right. Reuses the existing
/// `GoldHangingsListCubit` and `GoldHangingsUnhangCubit` unchanged; opens the
/// already-desktop-redesigned picker for the Hang flow.
class GoldHangingsDesktopScreen extends StatefulWidget {
  const GoldHangingsDesktopScreen({super.key});

  @override
  State<GoldHangingsDesktopScreen> createState() =>
      _GoldHangingsDesktopScreenState();
}

class _GoldHangingsDesktopScreenState
    extends State<GoldHangingsDesktopScreen> {
  HangedGoldModel? _selected;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<GoldHangingsListCubit>().fetchHanged();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPicker() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => GoldHangingsAvailableCubit(getIt())),
            BlocProvider(create: (_) => GoldHangingsHangCubit(getIt())),
          ],
          child: const GoldHangingsPickerScreen(),
        ),
      ),
    ).then((didHang) {
      if (mounted && didHang == true) {
        context.read<GoldHangingsListCubit>().fetchHanged();
      }
    });
  }

  Future<void> _confirmUnhang(HangedGoldModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('gold_hangings.unhangConfirmTitle'.tr()),
        content: Text(
          'gold_hangings.unhangConfirmBody'.tr(args: [item.name]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('gold_hangings.unhang'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<GoldHangingsUnhangCubit>().unhang(item.id);
    }
  }

  List<HangedGoldModel> _filter(List<HangedGoldModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.id.toString().contains(q) ||
          item.kind.name.toLowerCase().contains(q) ||
          item.carat.carat.toLowerCase().contains(q) ||
          (item.hangedBy?.name.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoldHangingsUnhangCubit, GoldHangingsUnhangState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (data) {
            successSnackBar(msg: data.message, context: context);
            context.read<GoldHangingsListCubit>().fetchHanged();
            context.read<GoldHangingsUnhangCubit>().reset();
            setState(() => _selected = null);
          },
          error: (messages) {
            failureSnackBar(msg: messages.join('\n'), context: context);
            context.read<GoldHangingsUnhangCubit>().reset();
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DesktopHeader(
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _query = v),
              onAddNew: _openPicker,
              onRefresh: () =>
                  context.read<GoldHangingsListCubit>().fetchHanged(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<GoldHangingsListCubit,
                  GoldHangingsListState>(
                builder: (context, state) => state.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (message) => _DesktopError(
                    message: message,
                    onRetry: () =>
                        context.read<GoldHangingsListCubit>().fetchHanged(),
                  ),
                  success: (items) => _buildBody(_filter(items)),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<HangedGoldModel> items) {
    if (items.isEmpty) {
      return Center(
        child: _EmptyCard(onAddNew: _openPicker, hasQuery: _query.isNotEmpty),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        if (!wide) {
          return _ListPane(
            items: items,
            selectedId: _selected?.id,
            onSelect: (item) => setState(() => _selected = item),
            onUnhang: _confirmUnhang,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: _ListPane(
                items: items,
                selectedId: _selected?.id,
                onSelect: (item) => setState(() => _selected = item),
                onUnhang: _confirmUnhang,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _selected == null
                  ? _SelectAPrompt()
                  : BlocBuilder<GoldHangingsUnhangCubit,
                      GoldHangingsUnhangState>(
                      builder: (context, unhangState) {
                        final isUnhanging = unhangState.maybeWhen(
                          loading: (id) => id == _selected!.id,
                          orElse: () => false,
                        );
                        return _DetailPane(
                          item: _selected!,
                          isUnhanging: isUnhanging,
                          onUnhang: () => _confirmUnhang(_selected!),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddNew,
    required this.onRefresh,
  });
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddNew;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _accent.withValues(alpha: 0.14),
            child: const Icon(Icons.bookmark_added_rounded, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'gold_hangings.title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'gold_hangings.subtitle'.tr(),
                  style: AppFonts.body(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 240,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                hintText: 'common.search'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('common.refresh'.tr()),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _accent),
            onPressed: onAddNew,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('gold_hangings.hangProductShort'.tr()),
          ),
        ],
      ),
    );
  }
}

// ─── List pane ─────────────────────────────────────────────────────────────

class _ListPane extends StatelessWidget {
  const _ListPane({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.onUnhang,
  });
  final List<HangedGoldModel> items;
  final int? selectedId;
  final ValueChanged<HangedGoldModel> onSelect;
  final ValueChanged<HangedGoldModel> onUnhang;

  @override
  Widget build(BuildContext context) {
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _HangedRow(
          item: items[index],
          selected: items[index].id == selectedId,
          onTap: () => onSelect(items[index]),
          onUnhang: () => onUnhang(items[index]),
        ),
      ),
    );
  }
}

class _HangedRow extends StatelessWidget {
  const _HangedRow({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onUnhang,
  });
  final HangedGoldModel item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onUnhang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? _accent.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? _accent
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            _Thumbnail(url: item.image),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${item.id} · ${item.name}',
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.kind.name} • ${'common.carat'.tr()} ${item.carat.carat} • ${item.grams.toStringAsFixed(2)}g',
                    style: AppFonts.body(
                      fontSize: 11,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(
                  color: theme.colorScheme.error.withValues(alpha: 0.4),
                ),
              ),
              onPressed: onUnhang,
              icon: const Icon(Icons.bookmark_remove_outlined, size: 14),
              label: Text('gold_hangings.unhang'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null && url!.isNotEmpty)
          ? CachedNetworkImageWidget(imageUrl: url!, fit: BoxFit.cover)
          : Icon(
              Icons.image_outlined,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
    );
  }
}

// ─── Detail pane ───────────────────────────────────────────────────────────

class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.item,
    required this.isUnhanging,
    required this.onUnhang,
  });
  final HangedGoldModel item;
  final bool isUnhanging;
  final VoidCallback onUnhang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _Thumbnail(url: item.image),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppFonts.heading(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${item.id} · ${item.kind.name}',
                        style: AppFonts.body(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'common.carat'.tr(),
              value: item.carat.carat,
            ),
            _DetailRow(
              label: 'common.grams'.tr(),
              value: item.grams.toStringAsFixed(2),
            ),
            _DetailRow(
              label: 'common.mc'.tr(),
              value:
                  '${item.mc.toStringAsFixed(2)}${item.isMcInUsd ? ' (USD)' : ''}',
            ),
            _DetailRow(
              label: 'common.profit'.tr(),
              value: item.profit.toStringAsFixed(2),
            ),
            if (item.vendor != null)
              _DetailRow(
                label: 'common.vendor'.tr(),
                value: item.vendor!.name,
              ),
            const Divider(height: 24),
            _DetailRow(
              label: 'gold_hangings.hangedBy'.tr(),
              value: item.hangedBy?.name ?? '—',
            ),
            _DetailRow(
              label: 'orders.date'.tr(),
              value: _formatDate(item.hangedAt),
            ),
            if (item.hangNote != null && item.hangNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'gold_hangings.noteLabel'.tr(),
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.hangNote!,
                        style: AppFonts.body(fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: isUnhanging ? null : onUnhang,
              icon: isUnhanging
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_remove_outlined, size: 16),
              label: Text(
                'gold_hangings.unhang'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectAPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'gold_hangings.selectToView'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAddNew, required this.hasQuery});
  final VoidCallback onAddNew;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: DesktopCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              hasQuery
                  ? 'gold_hangings.noSearchResults'.tr()
                  : 'gold_hangings.emptyTitle'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'gold_hangings.emptyHint'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _accent),
              onPressed: onAddNew,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text('gold_hangings.hangProducts'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopError extends StatelessWidget {
  const _DesktopError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DesktopCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 36),
              const SizedBox(height: 12),
              Text(
                'common.somethingWentWrong'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 12)),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onRetry,
                child: Text('common.tryAgain'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} $hh:$mi';
  } catch (_) {
    return iso;
  }
}
