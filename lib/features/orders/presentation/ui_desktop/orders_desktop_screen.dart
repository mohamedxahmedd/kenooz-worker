import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_model.dart';
import 'package:kenooz_worker_app/features/orders/data/models/order_stats_model.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/current_orders_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/current_orders_state.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/ongoing_orders_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/ongoing_orders_state.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/order_action_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/order_action_state.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/orders_stats_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/orders_stats_state.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/past_orders_cubit.dart';
import 'package:kenooz_worker_app/features/orders/presentation/cubit/past_orders_state.dart';
import 'package:kenooz_worker_app/features/orders/presentation/ui/widgets/order_status_bottom_sheet.dart';

/// Desktop Orders screen. Tabbed data tables (Current / Ongoing / Past) with
/// inline row actions, plus a Stats tab. Selecting a row opens a right-side
/// detail panel showing every field of the order. All data is sourced from
/// the same cubits the mobile screen uses; no API or model changes.
class OrdersDesktopScreen extends StatefulWidget {
  const OrdersDesktopScreen({super.key});

  @override
  State<OrdersDesktopScreen> createState() => _OrdersDesktopScreenState();
}

class _OrdersDesktopScreenState extends State<OrdersDesktopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  OrderModel? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _selectedOrder = null);
    });
    _refreshAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    context.read<CurrentOrdersCubit>().fetchCurrentOrders();
    context.read<OngoingOrdersCubit>().fetchOngoingOrders();
    context.read<PastOrdersCubit>().fetchPastOrders();
    final stats = context.read<OrdersStatsCubit>();
    switch (stats.currentPeriod) {
      case 'week':
        stats.fetchWeekStats();
      case 'month':
        stats.fetchMonthStats();
      case 'year':
        stats.fetchYearStats();
      default:
        stats.fetchDayStats();
    }
  }

  void _onChangeStatus(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderStatusBottomSheet(
        currentStatus: order.status,
        onStatusSelected: (newStatus) {
          if (newStatus == order.status) return;
          context
              .read<OrderActionCubit>()
              .emitChangeStatus(order.id, newStatus);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<OrderActionCubit, OrderActionState<String>>(
      listener: _onOrderActionState,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesktopOrdersHeader(onRefresh: _refreshAll),
          Material(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'orders.current'.tr()),
                Tab(text: 'orders.ongoing'.tr()),
                Tab(text: 'orders.past'.tr()),
                Tab(text: 'orders.stats'.tr()),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CurrentTabBody(
                  onRowTap: (o) => setState(() => _selectedOrder = o),
                  selectedId: _selectedOrder?.id,
                  selectedOrder: _selectedOrder,
                  onChangeStatus: _onChangeStatus,
                ),
                _OngoingTabBody(
                  onRowTap: (o) => setState(() => _selectedOrder = o),
                  selectedId: _selectedOrder?.id,
                  selectedOrder: _selectedOrder,
                  onChangeStatus: _onChangeStatus,
                ),
                _PastTabBody(
                  onRowTap: (o) => setState(() => _selectedOrder = o),
                  selectedId: _selectedOrder?.id,
                  selectedOrder: _selectedOrder,
                  onChangeStatus: _onChangeStatus,
                ),
                const _StatsTabBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onOrderActionState(BuildContext context, OrderActionState<String> state) {
    switch (state) {
      case OrderActionLoading():
        EasyLoading.show();
      case OrderActionSuccess():
        EasyLoading.dismiss();
        successSnackBar(
          msg: 'common.rateUpdatedSuccessfully'.tr(),
          context: context,
        );
        _refreshAll();
      case OrderActionError(:final messages):
        EasyLoading.dismiss();
        failureSnackBar(msg: messages.join('\n'), context: context);
      case OrderActionInitial():
        break;
    }
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _DesktopOrdersHeader extends StatelessWidget {
  const _DesktopOrdersHeader({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: DesktopCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.10),
              child: Icon(Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders.title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'orders.subtitle'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('common.refresh'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab bodies ────────────────────────────────────────────────────────────

class _CurrentTabBody extends StatelessWidget {
  const _CurrentTabBody({
    required this.onRowTap,
    required this.selectedId,
    required this.selectedOrder,
    required this.onChangeStatus,
  });
  final ValueChanged<OrderModel> onRowTap;
  final int? selectedId;
  final OrderModel? selectedOrder;
  final ValueChanged<OrderModel> onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentOrdersCubit,
        CurrentOrdersState<List<OrderModel>>>(
      builder: (context, state) => switch (state) {
        CurrentOrdersInitial() || CurrentOrdersLoading() =>
          const Center(child: CircularProgressIndicator()),
        CurrentOrdersError(:final messages) => _DesktopErrorView(
            message: messages.join('\n'),
            onRetry: () =>
                context.read<CurrentOrdersCubit>().fetchCurrentOrders(),
          ),
        CurrentOrdersSuccess(:final data) => _OrdersTabContent(
            orders: data,
            emptyMessage: 'orders.noPendingOrders'.tr(),
            onRowTap: onRowTap,
            selectedId: selectedId,
            selectedOrder: selectedOrder,
            onAccept: (o) =>
                context.read<OrderActionCubit>().emitAcceptOrder(o.id),
            onReject: (o) =>
                context.read<OrderActionCubit>().emitRejectOrder(o.id),
            onChangeStatus: onChangeStatus,
            onMarkAsPaid: (o) =>
                context.read<OrderActionCubit>().emitMarkAsPaid(o.id),
          ),
      },
    );
  }
}

class _OngoingTabBody extends StatelessWidget {
  const _OngoingTabBody({
    required this.onRowTap,
    required this.selectedId,
    required this.selectedOrder,
    required this.onChangeStatus,
  });
  final ValueChanged<OrderModel> onRowTap;
  final int? selectedId;
  final OrderModel? selectedOrder;
  final ValueChanged<OrderModel> onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OngoingOrdersCubit,
        OngoingOrdersState<List<OrderModel>>>(
      builder: (context, state) => switch (state) {
        OngoingOrdersInitial() || OngoingOrdersLoading() =>
          const Center(child: CircularProgressIndicator()),
        OngoingOrdersError(:final messages) => _DesktopErrorView(
            message: messages.join('\n'),
            onRetry: () =>
                context.read<OngoingOrdersCubit>().fetchOngoingOrders(),
          ),
        OngoingOrdersSuccess(:final data) => _OrdersTabContent(
            orders: data,
            emptyMessage: 'orders.noOngoingOrders'.tr(),
            onRowTap: onRowTap,
            selectedId: selectedId,
            selectedOrder: selectedOrder,
            onAccept: (o) =>
                context.read<OrderActionCubit>().emitAcceptOrder(o.id),
            onReject: (o) =>
                context.read<OrderActionCubit>().emitRejectOrder(o.id),
            onChangeStatus: onChangeStatus,
            onMarkAsPaid: (o) =>
                context.read<OrderActionCubit>().emitMarkAsPaid(o.id),
          ),
      },
    );
  }
}

class _PastTabBody extends StatelessWidget {
  const _PastTabBody({
    required this.onRowTap,
    required this.selectedId,
    required this.selectedOrder,
    required this.onChangeStatus,
  });
  final ValueChanged<OrderModel> onRowTap;
  final int? selectedId;
  final OrderModel? selectedOrder;
  final ValueChanged<OrderModel> onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PastOrdersCubit, PastOrdersState<List<OrderModel>>>(
      builder: (context, state) => switch (state) {
        PastOrdersInitial() || PastOrdersLoading() =>
          const Center(child: CircularProgressIndicator()),
        PastOrdersError(:final messages) => _DesktopErrorView(
            message: messages.join('\n'),
            onRetry: () =>
                context.read<PastOrdersCubit>().fetchPastOrders(),
          ),
        PastOrdersSuccess(:final data) => _OrdersTabContent(
            orders: data,
            emptyMessage: 'orders.noPastOrders'.tr(),
            onRowTap: onRowTap,
            selectedId: selectedId,
            selectedOrder: selectedOrder,
            onAccept: (o) =>
                context.read<OrderActionCubit>().emitAcceptOrder(o.id),
            onReject: (o) =>
                context.read<OrderActionCubit>().emitRejectOrder(o.id),
            onChangeStatus: onChangeStatus,
            onMarkAsPaid: (o) =>
                context.read<OrderActionCubit>().emitMarkAsPaid(o.id),
          ),
      },
    );
  }
}

// ─── Tab content (data table + optional detail panel) ─────────────────────

class _OrdersTabContent extends StatelessWidget {
  const _OrdersTabContent({
    required this.orders,
    required this.emptyMessage,
    required this.onRowTap,
    required this.selectedId,
    required this.selectedOrder,
    required this.onAccept,
    required this.onReject,
    required this.onChangeStatus,
    required this.onMarkAsPaid,
  });

  final List<OrderModel> orders;
  final String emptyMessage;
  final ValueChanged<OrderModel> onRowTap;
  final int? selectedId;
  final OrderModel? selectedOrder;
  final ValueChanged<OrderModel> onAccept;
  final ValueChanged<OrderModel> onReject;
  final ValueChanged<OrderModel> onChangeStatus;
  final ValueChanged<OrderModel> onMarkAsPaid;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyView(message: emptyMessage);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _OrdersTableCard(
              orders: orders,
              onRowTap: onRowTap,
              selectedId: selectedId,
              onAccept: onAccept,
              onReject: onReject,
              onChangeStatus: onChangeStatus,
              onMarkAsPaid: onMarkAsPaid,
            ),
          ),
          if (selectedOrder != null) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _OrderDetailPanel(order: selectedOrder!),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrdersTableCard extends StatelessWidget {
  const _OrdersTableCard({
    required this.orders,
    required this.onRowTap,
    required this.selectedId,
    required this.onAccept,
    required this.onReject,
    required this.onChangeStatus,
    required this.onMarkAsPaid,
  });

  final List<OrderModel> orders;
  final ValueChanged<OrderModel> onRowTap;
  final int? selectedId;
  final ValueChanged<OrderModel> onAccept;
  final ValueChanged<OrderModel> onReject;
  final ValueChanged<OrderModel> onChangeStatus;
  final ValueChanged<OrderModel> onMarkAsPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.primary.withValues(alpha: 0.05),
            ),
              dataRowMinHeight: 44,
              dataRowMaxHeight: 48,
              columns: [
                DataColumn(label: Text('orders.id'.tr())),
                DataColumn(label: Text('orders.client'.tr())),
                DataColumn(label: Text('orders.type'.tr())),
                DataColumn(label: Text('orders.items'.tr()), numeric: true),
                DataColumn(label: Text('orders.total'.tr()), numeric: true),
                DataColumn(label: Text('orders.status'.tr())),
                DataColumn(label: Text('orders.date'.tr())),
                DataColumn(label: Text('orders.actions'.tr())),
              ],
              rows: [
                for (final order in orders)
                  DataRow(
                    selected: order.id == selectedId,
                    onSelectChanged: (_) => onRowTap(order),
                    cells: [
                      DataCell(Text('#${order.id}')),
                      DataCell(Text(
                        order.client?.name ??
                            'orders.unknownClient'.tr(),
                        overflow: TextOverflow.ellipsis,
                      )),
                      DataCell(Text(order.pickupType.toUpperCase())),
                      DataCell(Text(order.orderItems
                          .fold<int>(0, (acc, item) => acc + item.qty)
                          .toString())),
                      DataCell(Text(order.total.toStringAsFixed(2))),
                      DataCell(_StatusBadge(status: order.status)),
                      DataCell(Text(_formatDate(order.createdAt))),
                      DataCell(_RowActions(
                        order: order,
                        onAccept: onAccept,
                        onReject: onReject,
                        onChangeStatus: onChangeStatus,
                        onMarkAsPaid: onMarkAsPaid,
                      )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onChangeStatus,
    required this.onMarkAsPaid,
  });

  final OrderModel order;
  final ValueChanged<OrderModel> onAccept;
  final ValueChanged<OrderModel> onReject;
  final ValueChanged<OrderModel> onChangeStatus;
  final ValueChanged<OrderModel> onMarkAsPaid;

  @override
  Widget build(BuildContext context) {
    final status = order.status.toLowerCase();
    final canChangeStatus = const {
      'accepted',
      'processing',
      'on_the_way',
      'ready',
    }.contains(status);
    final canMarkPaid = order.isPaid != 1 &&
        const {
          'accepted',
          'processing',
          'on_the_way',
          'ready',
          'completed',
        }.contains(status);

    return PopupMenuButton<_RowAction>(
      tooltip: 'orders.actions'.tr(),
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (action) {
        switch (action) {
          case _RowAction.accept:
            onAccept(order);
          case _RowAction.reject:
            onReject(order);
          case _RowAction.changeStatus:
            onChangeStatus(order);
          case _RowAction.markAsPaid:
            onMarkAsPaid(order);
        }
      },
      itemBuilder: (context) => [
        if (status == 'pending') ...[
          PopupMenuItem(
            value: _RowAction.accept,
            child: _MenuRow(
              icon: Icons.check_circle_outline_rounded,
              label: 'orders.accept'.tr(),
              color: Colors.green,
            ),
          ),
          PopupMenuItem(
            value: _RowAction.reject,
            child: _MenuRow(
              icon: Icons.cancel_outlined,
              label: 'orders.reject'.tr(),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (canChangeStatus)
          PopupMenuItem(
            value: _RowAction.changeStatus,
            child: _MenuRow(
              icon: Icons.swap_horiz_rounded,
              label: 'orders.changeStatus'.tr(),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (canMarkPaid)
          PopupMenuItem(
            value: _RowAction.markAsPaid,
            child: _MenuRow(
              icon: Icons.payments_outlined,
              label: 'orders.markAsPaid'.tr(),
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}

enum _RowAction { accept, reject, changeStatus, markAsPaid }

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return const Color(0xFF2196F3);
      case 'processing':
        return const Color(0xFF3F51B5);
      case 'on_the_way':
        return const Color(0xFF009688);
      case 'ready':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'paid':
        return const Color(0xFF9C27B0);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: AppFonts.body(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _OrderDetailPanel extends StatelessWidget {
  const _OrderDetailPanel({required this.order});
  final OrderModel order;

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
                Icon(Icons.receipt_long_rounded,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${'orders.orderDetails'.tr()} #${order.id}',
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
                label: 'orders.client'.tr(),
                value: order.client?.name ?? 'orders.unknownClient'.tr()),
            _DetailRow(label: 'orders.type'.tr(), value: order.pickupType),
            _DetailRow(
                label: 'orders.date'.tr(),
                value: _formatDate(order.createdAt)),
            _DetailRow(
              label: 'orders.totalAmount'.tr(),
              value: order.total.toStringAsFixed(2),
              emphasize: true,
            ),
            if (order.shippingFee > 0)
              _DetailRow(
                label: 'orders.shippingFee'.tr(),
                value: order.shippingFee.toStringAsFixed(2),
              ),
            if ((order.discount ?? 0) > 0)
              _DetailRow(
                label: 'orders.discount'.tr(),
                value: '- ${order.discount!.toStringAsFixed(2)}',
              ),
            _DetailRow(
              label: 'orders.paid'.tr(),
              value: order.isPaid == 1
                  ? 'orders.paid'.tr()
                  : 'orders.unpaid'.tr(),
            ),
            if ((order.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'orders.notes'.tr(),
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(order.notes!, style: AppFonts.body(fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'orders.items'.tr(),
              style: AppFonts.heading(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in order.orderItems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product?.name ?? 'orders.unknownProduct'.tr()}  × ${item.qty}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.subtotal.toStringAsFixed(2),
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });
  final String label;
  final String value;
  final bool emphasize;

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
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppFonts.body(
                fontSize: emphasize ? 14 : 12,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: emphasize
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DesktopCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined,
                  size: 40,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5)),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopErrorView extends StatelessWidget {
  const _DesktopErrorView({required this.message, required this.onRetry});
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
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 12),
              ),
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

// ─── Stats tab ─────────────────────────────────────────────────────────────

class _StatsTabBody extends StatelessWidget {
  const _StatsTabBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersStatsCubit, OrdersStatsState<OrderStatsModel>>(
      builder: (context, state) {
        final cubit = context.read<OrdersStatsCubit>();
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PeriodSelector(
                current: cubit.currentPeriod,
                onChanged: (p) => switch (p) {
                  'week' => cubit.fetchWeekStats(),
                  'month' => cubit.fetchMonthStats(),
                  'year' => cubit.fetchYearStats(),
                  _ => cubit.fetchDayStats(),
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: switch (state) {
                  OrdersStatsInitial() || OrdersStatsLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  OrdersStatsError(:final messages) => _DesktopErrorView(
                      message: messages.join('\n'),
                      onRetry: () => cubit.fetchDayStats(),
                    ),
                  OrdersStatsSuccess(:final data) =>
                    _StatsContent(stats: data),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = ['day', 'week', 'month', 'year'];
    final labelKeys = {
      'day': 'orders.day',
      'week': 'orders.week',
      'month': 'orders.month',
      'year': 'orders.year',
    };
    return Wrap(
      spacing: 8,
      children: [
        for (final p in options)
          ChoiceChip(
            label: Text(labelKeys[p]!.tr()),
            selected: current == p,
            onSelected: (_) => onChanged(p),
          ),
      ],
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});
  final OrderStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'orders.ordersCount'.tr(),
                  value: stats.totalCount.toString(),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatTile(
                  icon: Icons.payments_outlined,
                  label: 'orders.revenueTotal'.tr(),
                  value: stats.totalAmount.toStringAsFixed(2),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'orders.breakdown'.tr(),
            style: AppFonts.heading(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (stats.entries.isEmpty)
            _EmptyView(message: 'orders.noEntriesForPeriod'.tr())
          else
            DesktopCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final entry in stats.entries.entries)
                    _BreakdownRow(
                      label: entry.key,
                      count: entry.value.count,
                      total: entry.value.total,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DesktopCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppFonts.heading(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.count,
    required this.total,
  });
  final String label;
  final int count;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        AppFonts.body(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '$count ${'orders.length'.tr()}',
                  style: AppFonts.body(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            total.toStringAsFixed(2),
            style: AppFonts.heading(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date helper ───────────────────────────────────────────────────────────

String _formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  } catch (_) {
    return iso;
  }
}
