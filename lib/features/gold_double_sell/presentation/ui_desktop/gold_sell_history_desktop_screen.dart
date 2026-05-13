import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_buy_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_buy_item_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/client_search_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_kinds_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_sell_history_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_sell_history_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui_desktop/gold_double_sell_desktop_screen.dart';

const Color _goldAccent = Color(0xFFCBA135);

/// Desktop Gold Sell History. Header card + "Add new" CTA + searchable
/// data table of transactions. Row click opens the full detail dialog with
/// every sell item field (carat, kind, vendor, grams, loss, mc, profit,
/// gram price, total) and every nested buy item (carat, box, grams, loss,
/// net grams, gram price, total). Reuses `GoldSellHistoryCubit` unchanged.
class GoldSellHistoryDesktopScreen extends StatefulWidget {
  const GoldSellHistoryDesktopScreen({super.key});

  @override
  State<GoldSellHistoryDesktopScreen> createState() =>
      _GoldSellHistoryDesktopScreenState();
}

class _GoldSellHistoryDesktopScreenState
    extends State<GoldSellHistoryDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<GoldSellHistoryCubit>().fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => DoubleSellPreloadCubit(getIt())),
            BlocProvider(create: (_) => ClientSearchCubit(getIt())),
            BlocProvider(create: (_) => ProductLookupCubit(getIt())),
            BlocProvider(create: (_) => GoldKindsCubit(getIt())),
            BlocProvider(create: (_) => DoubleSellSubmitCubit(getIt())),
            BlocProvider(create: (_) => CreateVendorCubit(getIt())),
          ],
          child: const GoldDoubleSellDesktopScreen(),
        ),
      ),
    ).then((_) {
      if (mounted) context.read<GoldSellHistoryCubit>().fetchHistory();
    });
  }

  List<GoldSellHistoryModel> _filter(List<GoldSellHistoryModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((row) {
      return row.client.name.toLowerCase().contains(q) ||
          row.worker.name.toLowerCase().contains(q) ||
          row.id.toString().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderCard(
            title: 'gold_double_sell.history'.tr(),
            subtitle: 'gold_double_sell.historySubtitle'.tr(),
            accent: _goldAccent,
            onAddNew: _openNewOrder,
            onRefresh: () =>
                context.read<GoldSellHistoryCubit>().fetchHistory(),
            searchController: _searchController,
            onSearchChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<GoldSellHistoryCubit, GoldSellHistoryState>(
              builder: (context, state) => switch (state) {
                GoldSellHistoryInitial() || GoldSellHistoryLoading() =>
                  const Center(child: CircularProgressIndicator()),
                GoldSellHistoryError(:final message) => _ErrorCard(
                    message: message,
                    onRetry: () =>
                        context.read<GoldSellHistoryCubit>().fetchHistory(),
                  ),
                GoldSellHistorySuccess(:final sells) => () {
                    final filtered = _filter(sells);
                    if (filtered.isEmpty) {
                      return _EmptyCard(onAddNew: _openNewOrder);
                    }
                    return _HistoryTable(
                      rows: filtered,
                      accent: _goldAccent,
                    );
                  }(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onAddNew,
    required this.onRefresh,
    required this.searchController,
    required this.onSearchChanged,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onAddNew;
  final VoidCallback onRefresh;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(Icons.history_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: onAddNew,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('common.addNew'.tr()),
          ),
        ],
      ),
    );
  }
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({required this.rows, required this.accent});
  final List<GoldSellHistoryModel> rows;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStatePropertyAll(
                accent.withValues(alpha: 0.06),
              ),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columns: [
                DataColumn(label: Text('orders.id'.tr())),
                DataColumn(label: Text('orders.client'.tr())),
                DataColumn(label: Text('common.worker'.tr())),
                DataColumn(label: Text('common.sellItemsSec'.tr()), numeric: true),
                DataColumn(
                  label: Text('common.totalLabel'.tr()),
                  numeric: true,
                ),
                DataColumn(label: Text('orders.date'.tr())),
                DataColumn(label: Text('orders.actions'.tr())),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(Text('#${row.id}')),
                      DataCell(Text(row.client.name)),
                      DataCell(Text(row.worker.name)),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(row.itemCount.toString()),
                          const SizedBox(width: 6),
                          if (row.hasBuy)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Double',
                                style: AppFonts.body(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                        ],
                      )),
                      DataCell(Text(
                        row.total.toStringAsFixed(2),
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      )),
                      DataCell(Text(row.sellDate)),
                      DataCell(TextButton.icon(
                        onPressed: () => _openDetail(context, row),
                        icon: const Icon(Icons.visibility_outlined,
                            size: 16),
                        label: Text('orders.view'.tr()),
                      )),
                    ],
                    onSelectChanged: (_) => _openDetail(context, row),
                  ),
              ],
            ),
          ),
        ),
      );
  }

  void _openDetail(BuildContext context, GoldSellHistoryModel row) {
    showDialog(
      context: context,
      builder: (_) => _DetailDialog(row: row, accent: accent),
    );
  }
}

class _DetailDialog extends StatelessWidget {
  const _DetailDialog({required this.row, required this.accent});
  final GoldSellHistoryModel row;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 1100, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.diamond_outlined, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'gold_double_sell.history'.tr()} • #${row.id}',
                      style: AppFonts.heading(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _SummaryChip(
                    icon: Icons.event_outlined,
                    label: row.sellDate,
                    color: accent,
                  ),
                  _SummaryChip(
                    icon: Icons.payments_outlined,
                    label: row.total.toStringAsFixed(2),
                    color: accent,
                  ),
                  _SummaryChip(
                    icon: Icons.person_outline_rounded,
                    label:
                        '${row.client.name} • ${row.client.phone}',
                    color: accent,
                  ),
                  _SummaryChip(
                    icon: Icons.engineering_outlined,
                    label: row.worker.name,
                    color: accent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: 'common.sellItemsSec'.tr(),
                        accent: accent,
                      ),
                      const SizedBox(height: 8),
                      _SellItemsTable(items: row.goldSellItems),
                      if (row.goldBuys.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionHeader(
                          title: 'common.buyItemsSec'.tr(),
                          accent: accent,
                        ),
                        const SizedBox(height: 8),
                        for (final buy in row.goldBuys)
                          _BuyGroup(buy: buy, accent: accent),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.accent});
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: AppFonts.heading(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

class _SellItemsTable extends StatelessWidget {
  const _SellItemsTable({required this.items});
  final List<GoldSellItemHistoryModel> items;

  String _typeLabel(GoldSellItemType t) => switch (t) {
        GoldSellItemType.inside => 'common.inside'.tr(),
        GoldSellItemType.box => 'common.boxType'.tr(),
        GoldSellItemType.outside => 'common.outside'.tr(),
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columns: [
          const DataColumn(label: Text('#')),
          DataColumn(label: Text('orders.type'.tr())),
          DataColumn(label: Text('common.name'.tr())),
          DataColumn(label: Text('common.carat'.tr())),
          DataColumn(label: Text('common.kind'.tr())),
          DataColumn(label: Text('common.vendor'.tr())),
          DataColumn(label: Text('common.grams'.tr()), numeric: true),
          DataColumn(label: Text('common.loss'.tr()), numeric: true),
          DataColumn(label: Text('common.mc'.tr()), numeric: true),
          DataColumn(label: Text('common.profit'.tr()), numeric: true),
          DataColumn(label: Text('common.gramPrice'.tr()), numeric: true),
          DataColumn(label: Text('common.totalLabel'.tr()), numeric: true),
        ],
        rows: [
          for (var i = 0; i < items.length; i++) ...[
            DataRow(cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(_typeLabel(items[i].itemType))),
              DataCell(Text(items[i].goldName ?? items[i].boxName ?? '—')),
              DataCell(Text(items[i].caratLabel)),
              DataCell(Text(items[i].kindName)),
              DataCell(Text(items[i].vendorName)),
              DataCell(Text(items[i].grams.toStringAsFixed(2))),
              DataCell(Text(items[i].loss?.toStringAsFixed(2) ?? '—')),
              DataCell(Text(items[i].mc.toStringAsFixed(2))),
              DataCell(Text(items[i].profit.toStringAsFixed(2))),
              DataCell(Text(items[i].gramPrice.toStringAsFixed(2))),
              DataCell(Text(items[i].price.toStringAsFixed(2))),
            ]),
          ],
        ],
      ),
    );
  }
}

class _BuyGroup extends StatelessWidget {
  const _BuyGroup({required this.buy, required this.accent});
  final GoldBuyHistoryModel buy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Buy #${buy.id}',
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const Spacer(),
              Text(
                buy.total.toStringAsFixed(2),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _BuyItemsTable(items: buy.items),
        ],
      ),
    );
  }
}

class _BuyItemsTable extends StatelessWidget {
  const _BuyItemsTable({required this.items});
  final List<GoldBuyItemHistoryModel> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columns: [
          const DataColumn(label: Text('#')),
          DataColumn(label: Text('common.carat'.tr())),
          DataColumn(label: Text('common.box'.tr())),
          DataColumn(label: Text('common.grams'.tr()), numeric: true),
          DataColumn(label: Text('common.loss'.tr()), numeric: true),
          DataColumn(label: Text('common.netGrams'.tr()), numeric: true),
          DataColumn(label: Text('common.gramPrice'.tr()), numeric: true),
          DataColumn(label: Text('common.totalLabel'.tr()), numeric: true),
        ],
        rows: [
          for (var i = 0; i < items.length; i++)
            DataRow(cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(items[i].caratLabel)),
              DataCell(Text(items[i].boxName ?? '—')),
              DataCell(Text(items[i].grams.toStringAsFixed(2))),
              DataCell(Text(items[i].loss.toStringAsFixed(2))),
              DataCell(Text(items[i].netGrams.toStringAsFixed(2))),
              DataCell(Text(items[i].gramPrice.toStringAsFixed(2))),
              DataCell(Text(items[i].price.toStringAsFixed(2))),
            ]),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAddNew});
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DesktopCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 40),
              const SizedBox(height: 12),
              Text(
                'common.no_records'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _goldAccent),
                onPressed: onAddNew,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text('common.addNew'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
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
