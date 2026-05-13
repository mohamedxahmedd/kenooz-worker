import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_record_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_unified_sell_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_sell_item_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_sell_record_history_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_history_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_history_state.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui_desktop/diamond_sell_desktop_screen.dart';

const Color _diamondAccent = Color(0xFF64B5F6);
const Color _stoneAccent = Color(0xFF9C89B8);

/// Desktop Diamond Sell History. Unified rows mix diamond + stone in one
/// transaction; the detail dialog splits them back into two clearly-labelled
/// sections, each rendered as its own data table.
class DiamondSellHistoryDesktopScreen extends StatefulWidget {
  const DiamondSellHistoryDesktopScreen({super.key});

  @override
  State<DiamondSellHistoryDesktopScreen> createState() =>
      _DiamondSellHistoryDesktopScreenState();
}

class _DiamondSellHistoryDesktopScreenState
    extends State<DiamondSellHistoryDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<DiamondSellHistoryCubit>().fetchHistory();
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
            BlocProvider(create: (_) => DiamondSellPreloadCubit(getIt())),
            BlocProvider(create: (_) => DiamondClientSearchCubit(getIt())),
            BlocProvider(create: (_) => DiamondProductLookupCubit(getIt())),
            BlocProvider(create: (_) => DiamondSellSubmitCubit(getIt())),
          ],
          child: const DiamondSellDesktopScreen(),
        ),
      ),
    ).then((_) {
      if (mounted) context.read<DiamondSellHistoryCubit>().fetchHistory();
    });
  }

  List<DiamondUnifiedSellHistoryModel> _filter(
      List<DiamondUnifiedSellHistoryModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((row) {
      return row.client.name.toLowerCase().contains(q) ||
          row.worker.name.toLowerCase().contains(q) ||
          row.unifiedId.toLowerCase().contains(q);
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
            onAddNew: _openNewOrder,
            onRefresh: () =>
                context.read<DiamondSellHistoryCubit>().fetchHistory(),
            searchController: _searchController,
            onSearchChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<DiamondSellHistoryCubit,
                DiamondSellHistoryState>(
              builder: (context, state) => switch (state) {
                DiamondSellHistoryInitial() ||
                DiamondSellHistoryLoading() =>
                  const Center(child: CircularProgressIndicator()),
                DiamondSellHistoryError(:final message) => _ErrorCard(
                    message: message,
                    onRetry: () => context
                        .read<DiamondSellHistoryCubit>()
                        .fetchHistory(),
                  ),
                DiamondSellHistorySuccess(:final sells) => () {
                    final filtered = _filter(sells);
                    if (filtered.isEmpty) {
                      return _EmptyCard(onAddNew: _openNewOrder);
                    }
                    return _HistoryTable(rows: filtered);
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
    required this.onAddNew,
    required this.onRefresh,
    required this.searchController,
    required this.onSearchChanged,
  });

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
            backgroundColor: _diamondAccent.withValues(alpha: 0.16),
            child: const Icon(Icons.diamond_outlined, color: _diamondAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diamond & Stone History',
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unified sell orders',
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
            style: FilledButton.styleFrom(backgroundColor: _diamondAccent),
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
  const _HistoryTable({required this.rows});
  final List<DiamondUnifiedSellHistoryModel> rows;

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
                _diamondAccent.withValues(alpha: 0.08),
              ),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columns: [
                DataColumn(label: Text('orders.id'.tr())),
                DataColumn(label: Text('orders.client'.tr())),
                DataColumn(label: Text('common.worker'.tr())),
                DataColumn(
                  label: Text('common.diamondColumn'.tr()),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('common.stoneColumn'.tr()),
                  numeric: true,
                ),
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
                      DataCell(Text(_shortId(row.unifiedId))),
                      DataCell(Text(row.client.name)),
                      DataCell(Text(row.worker.name)),
                      DataCell(Text(row.totalDiamondItems.toString())),
                      DataCell(Text(row.totalStoneItems.toString())),
                      DataCell(Text(
                        row.grandTotal.toStringAsFixed(2),
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _diamondAccent,
                        ),
                      )),
                      DataCell(Text(row.sellDate)),
                      DataCell(TextButton.icon(
                        onPressed: () => _openDetail(context, row),
                        icon:
                            const Icon(Icons.visibility_outlined, size: 16),
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

  String _shortId(String id) =>
      id.length > 10 ? '${id.substring(0, 8)}…' : id;

  void _openDetail(
      BuildContext context, DiamondUnifiedSellHistoryModel row) {
    showDialog(
      context: context,
      builder: (_) => _DetailDialog(row: row),
    );
  }
}

class _DetailDialog extends StatelessWidget {
  const _DetailDialog({required this.row});
  final DiamondUnifiedSellHistoryModel row;

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
                  const Icon(Icons.diamond_outlined, color: _diamondAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diamond & Stone • ${row.unifiedId}',
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
                  _Chip(icon: Icons.event_outlined, label: row.sellDate),
                  _Chip(
                    icon: Icons.payments_outlined,
                    label: row.grandTotal.toStringAsFixed(2),
                  ),
                  _Chip(
                    icon: Icons.person_outline_rounded,
                    label: '${row.client.name} • ${row.client.phone}',
                  ),
                  _Chip(
                    icon: Icons.engineering_outlined,
                    label: row.worker.name,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (row.diamondSells.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.diamond_outlined,
                          title:
                              '${'common.diamondColumn'.tr()} • ${row.totalDiamondItems}',
                          color: _diamondAccent,
                        ),
                        const SizedBox(height: 8),
                        for (final record in row.diamondSells)
                          _DiamondRecord(record: record),
                      ],
                      if (row.stoneSells.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionHeader(
                          icon: Icons.scatter_plot_rounded,
                          title:
                              '${'common.stoneColumn'.tr()} • ${row.totalStoneItems}',
                          color: _stoneAccent,
                        ),
                        const SizedBox(height: 8),
                        for (final record in row.stoneSells)
                          _StoneRecord(record: record),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _diamondAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _diamondAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _diamondAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppFonts.heading(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiamondRecord extends StatelessWidget {
  const _DiamondRecord({required this.record});
  final DiamondSellRecordHistoryModel record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Diamond #${record.id}',
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _diamondAccent,
                  )),
              const Spacer(),
              Text(
                record.total.toStringAsFixed(2),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _diamondAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _DiamondItemsTable(items: record.items),
        ],
      ),
    );
  }
}

class _StoneRecord extends StatelessWidget {
  const _StoneRecord({required this.record});
  final StoneSellRecordHistoryModel record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Stone #${record.id}',
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _stoneAccent,
                  )),
              const Spacer(),
              Text(
                record.total.toStringAsFixed(2),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _stoneAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _StoneItemsTable(items: record.items),
        ],
      ),
    );
  }
}

class _DiamondItemsTable extends StatelessWidget {
  const _DiamondItemsTable({required this.items});
  final List<DiamondSellItemHistoryModel> items;

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
          DataColumn(label: Text('common.name'.tr())),
          DataColumn(label: Text('common.kind'.tr())),
          DataColumn(label: Text('common.vendor'.tr())),
          DataColumn(label: Text('common.weightCarats'.tr()), numeric: true),
          DataColumn(label: Text('common.priceUsd'.tr()), numeric: true),
          DataColumn(label: Text('common.priceEgp'.tr()), numeric: true),
        ],
        rows: [
          for (var i = 0; i < items.length; i++)
            DataRow(cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(items[i].diamondName)),
              DataCell(Text(items[i].kindName)),
              DataCell(Text(items[i].vendorName)),
              DataCell(Text(items[i].diamondWeight.toStringAsFixed(2))),
              DataCell(Text(items[i].dollars.toStringAsFixed(2))),
              DataCell(Text(items[i].price.toStringAsFixed(2))),
            ]),
        ],
      ),
    );
  }
}

class _StoneItemsTable extends StatelessWidget {
  const _StoneItemsTable({required this.items});
  final List<StoneSellItemHistoryModel> items;

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
          DataColumn(label: Text('common.name'.tr())),
          DataColumn(label: Text('common.company'.tr())),
          DataColumn(label: Text('common.weightCarats'.tr()), numeric: true),
          DataColumn(label: Text('common.priceUsd'.tr()), numeric: true),
          DataColumn(label: Text('common.priceEgp'.tr()), numeric: true),
        ],
        rows: [
          for (var i = 0; i < items.length; i++)
            DataRow(cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(items[i].stoneName)),
              DataCell(Text(items[i].companyName)),
              DataCell(Text(items[i].weight.toStringAsFixed(2))),
              DataCell(Text(items[i].dollars.toStringAsFixed(2))),
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
                style:
                    FilledButton.styleFrom(backgroundColor: _diamondAccent),
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
