import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/create_carat_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_preload_data.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/gold_buy_request_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/models/sell_find_model.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_client_search_state.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_create_carat_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_create_carat_state.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_preload_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_preload_state.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_sell_link_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_sell_link_state.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_submit_cubit.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/cubit/gold_buy_submit_state.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_client_tab.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_create_carat_sheet.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_create_client_sheet.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_payment_section.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_product_section.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_sell_link_section.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_source_section.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_vendor_tab.dart';
import 'package:kenooz_worker_app/features/gold_buy/presentation/ui/widgets/gold_buy_worker_selector.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/currency_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_create_vendor_sheet.dart';

const Color _goldAccent = Color(0xFFCBA135);

/// Desktop Gold Buy. Desktop-native chrome (header card, max-width form,
/// sticky summary + submit on the right) backed by the existing cubits,
/// validation, sub-widgets, and submit flow from the mobile screen. Every
/// data field, error path, and sheet behavior is preserved.
class GoldBuyDesktopScreen extends StatefulWidget {
  const GoldBuyDesktopScreen({super.key});

  @override
  State<GoldBuyDesktopScreen> createState() => _GoldBuyDesktopScreenState();
}

class _GoldBuyDesktopScreenState extends State<GoldBuyDesktopScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoldBuyPreloadCubit>().fetchPreloadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<GoldBuySubmitCubit, GoldBuySubmitState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => EasyLoading.show(),
          success: (data) {
            EasyLoading.dismiss();
            successSnackBar(
              msg: 'gold_buy.submitSuccess'.tr(),
              context: context,
            );
            Navigator.pop(context);
          },
          error: (messages) {
            EasyLoading.dismiss();
            failureSnackBar(msg: messages.join('\n'), context: context);
          },
        );
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Column(
          children: [
            const _DesktopHeader(),
            Expanded(
              child: BlocBuilder<GoldBuyPreloadCubit, GoldBuyPreloadState>(
                builder: (context, state) => state.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (messages) => _DesktopError(
                    message: messages.join('\n'),
                    onRetry: () => context
                        .read<GoldBuyPreloadCubit>()
                        .fetchPreloadData(),
                  ),
                  success: (data) => _GoldBuyDesktopFormView(preloadData: data),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: DesktopCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            IconButton(
              tooltip: 'menu.back'.tr(),
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 20,
              backgroundColor: _goldAccent.withValues(alpha: 0.16),
              child: const Icon(Icons.savings_outlined, color: _goldAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'gold_buy.title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'gold_buy.subtitle'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65),
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

// ─── Form view (preserves every field from mobile) ─────────────────────────

class _GoldBuyDesktopFormView extends StatefulWidget {
  const _GoldBuyDesktopFormView({required this.preloadData});
  final GoldBuyPreloadData preloadData;

  @override
  State<_GoldBuyDesktopFormView> createState() =>
      _GoldBuyDesktopFormViewState();
}

class _GoldBuyDesktopFormViewState extends State<_GoldBuyDesktopFormView> {
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  ShopWorkerModel? _selectedWorker;
  ClientModel? _selectedClient;
  GoldVendorModel? _selectedVendor;
  late List<GoldVendorModel> _vendors;
  int? _linkedSellId;

  final List<Map<String, dynamic>> _products = [];
  final List<GoldBuyPaymentEntry> _paymentEntries = [];

  @override
  void initState() {
    super.initState();
    _selectedWorker = widget.preloadData.workers.isNotEmpty
        ? widget.preloadData.workers.first
        : null;
    _vendors = List<GoldVendorModel>.from(widget.preloadData.vendors);
  }

  @override
  void dispose() {
    _clientSearchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalBuyPrice => _products.fold<double>(
        0,
        (sum, p) => sum + ((p['buy_price'] as num?)?.toDouble() ?? 0),
      );

  double get _totalPaid =>
      _paymentEntries.fold<double>(0, (sum, e) => sum + e.cash);

  List<CurrencyModel> get _availableCurrencies {
    final byId = <int, CurrencyModel>{};
    for (final account in widget.preloadData.accounts) {
      byId.putIfAbsent(
        account.currencyId,
        () => CurrencyModel(
          id: account.currencyId,
          name: account.currencyCode,
          code: account.currencyCode,
          price: account.currencyPrice,
        ),
      );
    }
    return byId.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GoldBuyClientSearchCubit, GoldBuyClientSearchState>(
          listener: (context, state) {
            state.whenOrNull(
              found: (client) {
                setState(() {
                  _selectedClient = client;
                  _selectedVendor = null;
                });
              },
              created: (client) {
                setState(() {
                  _selectedClient = client;
                  _selectedVendor = null;
                });
                successSnackBar(
                  msg: 'common.clientCreated'.tr(),
                  context: context,
                );
              },
              error: (messages) {
                failureSnackBar(msg: messages.join('\n'), context: context);
              },
            );
          },
        ),
        BlocListener<GoldBuySellLinkCubit, GoldBuySellLinkState>(
          listener: (context, state) {
            state.whenOrNull(
              foundSingle: (sell) => setState(() => _linkedSellId = sell.id),
              notFound: () {
                failureSnackBar(
                  msg: 'gold_buy.sellOrderNotFound'.tr(),
                  context: context,
                );
              },
              error: (messages) {
                failureSnackBar(msg: messages.join('\n'), context: context);
              },
            );
          },
        ),
        BlocListener<GoldBuyCreateCaratCubit, GoldBuyCreateCaratState>(
          listener: (context, state) {
            state.whenOrNull(
              loading: () => EasyLoading.show(),
              success: (carat) {
                EasyLoading.dismiss();
                successSnackBar(
                  msg: 'gold_buy.caratCreatedSuccess'.tr(
                    namedArgs: {'carat': carat.carat},
                  ),
                  context: context,
                );
                context.read<GoldBuyCreateCaratCubit>().resetState();
              },
              error: (messages) {
                EasyLoading.dismiss();
                failureSnackBar(msg: messages.join('\n'), context: context);
              },
            );
          },
        ),
        BlocListener<CreateVendorCubit, CreateVendorState>(
          listener: (context, state) {
            state.whenOrNull(
              loading: () => EasyLoading.show(),
              success: (vendor) {
                EasyLoading.dismiss();
                final createdVendor = GoldVendorModel(
                  id: vendor.id,
                  name: vendor.name,
                  caratId: vendor.caratId,
                  currencyId: vendor.currencyId,
                  gold: 0,
                  cash: 0,
                );
                setState(() {
                  _vendors = [
                    createdVendor,
                    ..._vendors.where((v) => v.id != createdVendor.id),
                  ];
                  _selectedVendor = createdVendor;
                  _selectedClient = null;
                  _linkedSellId = null;
                });
                context.read<GoldBuyClientSearchCubit>().clearClient();
                context.read<GoldBuySellLinkCubit>().clearLink();
                successSnackBar(
                  msg: 'common.vendorCreated'.tr(),
                  context: context,
                );
              },
              error: (messages) {
                EasyLoading.dismiss();
                failureSnackBar(msg: messages.join('\n'), context: context);
              },
            );
          },
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;
                final formColumn = _buildFormColumn();
                final summaryColumn = _DesktopSummaryPanel(
                  totalBuyPrice: _totalBuyPrice,
                  totalPaid: _totalPaid,
                  onSubmit: _submit,
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      formColumn,
                      const SizedBox(height: 16),
                      summaryColumn,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: formColumn),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: summaryColumn),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<GoldBuyClientSearchCubit, GoldBuyClientSearchState>(
            builder: (context, clientState) {
              return GoldBuySourceSection(
                onTabChanged: (index) {
                  if (index == 0) {
                    setState(() => _selectedVendor = null);
                  } else {
                    setState(() {
                      _selectedClient = null;
                      _linkedSellId = null;
                    });
                    context.read<GoldBuyClientSearchCubit>().clearClient();
                    context.read<GoldBuySellLinkCubit>().clearLink();
                  }
                },
                clientTab: GoldBuyClientTab(
                  searchController: _clientSearchController,
                  state: clientState,
                  selectedClient: _selectedClient,
                  onSearch: () => context
                      .read<GoldBuyClientSearchCubit>()
                      .searchClient(_clientSearchController.text),
                  onOpenCreateClientSheet: _openCreateClientSheet,
                  onClear: () {
                    setState(() {
                      _selectedClient = null;
                      _linkedSellId = null;
                    });
                    context.read<GoldBuyClientSearchCubit>().clearClient();
                    context.read<GoldBuySellLinkCubit>().clearLink();
                  },
                ),
                vendorTab: GoldBuyVendorTab(
                  vendors: _vendors,
                  selectedVendor: _selectedVendor,
                  onChanged: (vendor) {
                    setState(() => _selectedVendor = vendor);
                  },
                  onOpenCreateVendorSheet: _openCreateVendorSheet,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: GoldBuyWorkerSelector(
            workers: widget.preloadData.workers,
            selectedWorker: _selectedWorker,
            onChanged: (worker) => setState(() => _selectedWorker = worker),
          ),
        ),
        if (_selectedVendor == null) ...[
          const SizedBox(height: 12),
          DesktopCard(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<GoldBuySellLinkCubit, GoldBuySellLinkState>(
              builder: (context, sellLinkState) {
                return GoldBuySellLinkSection(
                  state: sellLinkState,
                  linkedSellId: _linkedSellId,
                  onClear: () {
                    setState(() => _linkedSellId = null);
                    context.read<GoldBuySellLinkCubit>().clearLink();
                  },
                  onSearchById: (id) =>
                      context.read<GoldBuySellLinkCubit>().findByOrderId(id),
                  onSearchByClient: (term) =>
                      context.read<GoldBuySellLinkCubit>().findByClient(term),
                  onSelectSell: (SellFindModel sell) {
                    setState(() => _linkedSellId = sell.id);
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: GoldBuyProductSection(
            carats: widget.preloadData.carats,
            boxes: widget.preloadData.boxes,
            products: _products,
            onAdd: (product) => setState(() => _products.add(product)),
            onRemove: (index) => setState(() => _products.removeAt(index)),
            onCreateCarat: _openCreateCaratSheet,
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: GoldBuyPaymentSection(
            totalBuyPrice: _totalBuyPrice,
            accounts: widget.preloadData.accounts,
            entries: _paymentEntries,
            onAdd: (entry) => setState(() => _paymentEntries.add(entry)),
            onRemove: (index) =>
                setState(() => _paymentEntries.removeAt(index)),
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _notesController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'common.notesOptional'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────────

  Future<void> _openCreateClientSheet() async {
    final request = await showModalBottomSheet<CreateClientRequestModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const GoldBuyCreateClientSheet(),
      ),
    );
    if (!mounted || request == null) return;
    context.read<GoldBuyClientSearchCubit>().createClient(request);
  }

  Future<void> _openCreateCaratSheet() async {
    final request = await showModalBottomSheet<CreateCaratRequestModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const GoldBuyCreateCaratSheet(),
      ),
    );
    if (!mounted || request == null) return;
    context.read<GoldBuyCreateCaratCubit>().createCarat(request);
  }

  Future<void> _openCreateVendorSheet() async {
    if (widget.preloadData.carats.isEmpty || _availableCurrencies.isEmpty) {
      failureSnackBar(
        msg: 'gold_buy.missingCaratsOrCurrencies'.tr(),
        context: context,
      );
      return;
    }
    final request = await showModalBottomSheet<CreateVendorRequestModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DoubleSellCreateVendorSheet(
          carats: widget.preloadData.carats,
          currencies: _availableCurrencies,
        ),
      ),
    );
    if (!mounted || request == null) return;
    context.read<CreateVendorCubit>().createVendor(request);
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submit() {
    final validationMessage = _validateBeforeSubmit();
    if (validationMessage != null) {
      failureSnackBar(msg: validationMessage, context: context);
      return;
    }
    final request = GoldBuyRequestModel(
      workerId: _selectedWorker!.id,
      total: _totalBuyPrice,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      clientId: _selectedClient?.id,
      vendorId: _selectedVendor?.id,
      sellId: _selectedClient != null ? _linkedSellId : null,
      allAccounts: _paymentEntries.map((e) => e.toRequestMap()).toList(),
      products: _products,
    );
    context.read<GoldBuySubmitCubit>().submitGoldBuy(request);
  }

  String? _validateBeforeSubmit() {
    if (_selectedWorker == null) return 'common.pleaseSelectWorker'.tr();
    if (_selectedClient == null && _selectedVendor == null) {
      return 'gold_buy.pleaseSearchSelectClient'.tr();
    }
    if (_selectedClient != null && _selectedVendor != null) {
      return 'gold_buy.pleaseChooseOnlyOneSource'.tr();
    }
    if (_products.isEmpty) return 'gold_buy.addAtLeastOneProduct'.tr();
    if (_paymentEntries.isEmpty) return 'gold_buy.addAtLeastOnePayment'.tr();
    if (_totalBuyPrice <= 0) return 'gold_buy.totalBuyPriceMustBeGreater'.tr();
    return null;
  }
}

// ─── Sticky desktop summary + submit ───────────────────────────────────────

class _DesktopSummaryPanel extends StatelessWidget {
  const _DesktopSummaryPanel({
    required this.totalBuyPrice,
    required this.totalPaid,
    required this.onSubmit,
  });

  final double totalBuyPrice;
  final double totalPaid;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difference = totalBuyPrice - totalPaid;
    return DesktopCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_outlined, color: _goldAccent),
              const SizedBox(width: 8),
              Text(
                'common.summary'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'gold_buy.totalBuyPrice'.tr(),
            value: totalBuyPrice,
            emphasize: true,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'gold_buy.totalPaid'.tr(),
            value: totalPaid,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'gold_buy.difference'.tr(),
            value: difference,
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _goldAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onSubmit,
            child: Text(
              'gold_buy.submitGoldBuy'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });
  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: AppFonts.body(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const Spacer(),
        Text(
          value.toStringAsFixed(2),
          style: AppFonts.body(
            fontSize: emphasize ? 16 : 13,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            color: emphasize ? _goldAccent : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─── Error view ────────────────────────────────────────────────────────────

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
