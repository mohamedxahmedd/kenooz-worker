import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/helpers/price_calculator.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_vendor_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_preload_data.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/double_sell_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/shop_worker_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/client_search_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/client_search_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/create_vendor_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_preload_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/double_sell_submit_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_kinds_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/product_lookup_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_box_tab.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_buy_section.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_widget.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_client_section.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_create_client_sheet.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_create_vendor_sheet.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_inside_tab.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_item_tabs.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_outside_tab.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_payment_section.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_summary_widget.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_worker_selector.dart';

const Color _goldAccent = Color(0xFFCBA135);
const Color _buyAccent = Color(0xFF4CAF50);

/// Desktop Gold Double Sell. Reuses every existing widget — client section,
/// worker selector, the 3-tab item entry (Inside/Box/Outside), cart, payment
/// section, optional buy section + buy cart + deduction payment, summary
/// (with tax field) — inside a desktop chrome with a sticky totals panel on
/// the right. All pricing math, validation, and the submit payload structure
/// are preserved exactly from the mobile screen.
class GoldDoubleSellDesktopScreen extends StatefulWidget {
  const GoldDoubleSellDesktopScreen({super.key});

  @override
  State<GoldDoubleSellDesktopScreen> createState() =>
      _GoldDoubleSellDesktopScreenState();
}

class _GoldDoubleSellDesktopScreenState
    extends State<GoldDoubleSellDesktopScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DoubleSellPreloadCubit>().fetchPreloadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DoubleSellSubmitCubit, DoubleSellSubmitState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => EasyLoading.show(),
          success: (data) {
            EasyLoading.dismiss();
            successSnackBar(
              msg: 'gold_double_sell.submitSuccess'.tr(),
              context: context,
            );
            if (context.mounted) Navigator.pop(context);
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
              child: BlocBuilder<DoubleSellPreloadCubit,
                  DoubleSellPreloadState>(
                builder: (context, state) => state.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (messages) => _DesktopError(
                    message: messages.join('\n'),
                    onRetry: () => context
                        .read<DoubleSellPreloadCubit>()
                        .fetchPreloadData(),
                  ),
                  success: (data) =>
                      _GoldDoubleSellDesktopFormView(preloadData: data),
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
              child: const Icon(Icons.point_of_sale_outlined,
                  color: _goldAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'gold_double_sell.title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'gold_double_sell.subtitle'.tr(),
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

class _GoldDoubleSellDesktopFormView extends StatefulWidget {
  const _GoldDoubleSellDesktopFormView({required this.preloadData});
  final DoubleSellPreloadData preloadData;

  @override
  State<_GoldDoubleSellDesktopFormView> createState() =>
      _GoldDoubleSellDesktopFormViewState();
}

class _GoldDoubleSellDesktopFormViewState
    extends State<_GoldDoubleSellDesktopFormView> {
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _insideProductIdController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _taxController = TextEditingController(text: '0');

  ClientModel? _selectedClient;
  ShopWorkerModel? _selectedWorker;
  late List<GoldVendorModel> sellVendors;

  final List<DoubleSellCartItemModel> _sellItems = [];
  final List<DoubleSellCartItemModel> _buyItems = [];
  final List<DoubleSellPaymentEntry> _sellPaymentEntries = [];
  final List<DoubleSellPaymentEntry> _buyPaymentEntries = [];

  bool _showBuySection = false;

  @override
  void initState() {
    super.initState();
    sellVendors = List.of(widget.preloadData.vendors);
    _selectedWorker = widget.preloadData.workers.isNotEmpty
        ? widget.preloadData.workers.first
        : null;
  }

  @override
  void dispose() {
    _clientSearchController.dispose();
    _insideProductIdController.dispose();
    _notesController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  double get _taxPercent => double.tryParse(_taxController.text.trim()) ?? 0;

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ── Profit recalc copied verbatim from mobile so edited prices stay
  //    consistent with the underlying pricing model. ───────────────────────

  double _recalculateProfitFromEditedPrice(
    DoubleSellCartItemModel item,
    double editedPrice,
  ) {
    final payload = item.payload;
    final grams = _toDouble(payload['grams']);
    final mc = _toDouble(payload['mc']);
    final gramPrice = _toDouble(payload['gram_price']);

    if (grams <= 0) return _toDouble(payload['profit']);

    if (item.type == 'inside') {
      final rawIsMcDollar = payload['is_mc_d'];
      final isMcDollar = rawIsMcDollar is bool
          ? rawIsMcDollar
          : _toDouble(rawIsMcDollar) == 1;
      final effectiveMc = isMcDollar
          ? mc * widget.preloadData.usdRate.usd
          : mc;
      return (editedPrice / grams) - effectiveMc - gramPrice;
    }
    if (item.type == 'outside') {
      return (editedPrice / grams) - mc - gramPrice;
    }
    if (item.type == 'box') {
      final loss = _toDouble(payload['loss']);
      return editedPrice - ((grams - loss) * gramPrice) - (grams * mc);
    }
    return _toDouble(payload['profit']);
  }

  void _updateSellItemPrice(int index, double newPrice) {
    if (index < 0 || index >= _sellItems.length) return;
    if (newPrice <= 0) return;
    final currentItem = _sellItems[index];
    if ((newPrice - currentItem.price).abs() < 0.0001) return;
    final updatedPayload = Map<String, dynamic>.from(currentItem.payload);
    updatedPayload['profit'] =
        _recalculateProfitFromEditedPrice(currentItem, newPrice);
    updatedPayload['price'] = newPrice;
    setState(() {
      _sellItems[index] =
          currentItem.copyWith(price: newPrice, payload: updatedPayload);
    });
  }

  void _updateBuyItemPrice(int index, double newPrice) {
    if (index < 0 || index >= _buyItems.length) return;
    if (newPrice <= 0) return;
    final currentItem = _buyItems[index];
    if ((newPrice - currentItem.price).abs() < 0.0001) return;
    final updatedPayload = Map<String, dynamic>.from(currentItem.payload);
    updatedPayload['price'] = newPrice;
    setState(() {
      _buyItems[index] =
          currentItem.copyWith(price: newPrice, payload: updatedPayload);
    });
  }

  Future<void> _openCreateClientSheet() async {
    final request = await showModalBottomSheet<CreateClientRequestModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const DoubleSellCreateClientSheet(),
      ),
    );
    if (!mounted || request == null) return;
    context.read<ClientSearchCubit>().createClient(request);
  }

  Future<void> _openCreateVendorSheet() async {
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
          currencies: widget.preloadData.currencies,
        ),
      ),
    );
    if (!mounted || request == null) return;
    context.read<CreateVendorCubit>().createVendor(request);
  }

  void _submit(double finalTotal) {
    final validationMessage = _validateBeforeSubmit(finalTotal);
    if (validationMessage != null) {
      failureSnackBar(msg: validationMessage, context: context);
      return;
    }
    final insideProducts = _sellItems
        .where((item) => item.type == 'inside')
        .map((item) => item.payload)
        .toList();
    final outsideProducts = _sellItems
        .where((item) => item.type == 'outside')
        .map((item) => item.payload)
        .toList();
    final boxProducts = _sellItems
        .where((item) => item.type == 'box')
        .map((item) => item.payload)
        .toList();

    final request = DoubleSellRequestModel(
      clientId: _selectedClient!.id,
      workerId: _selectedWorker!.id,
      total: finalTotal,
      tax: _taxPercent,
      notes: _notesController.text.trim(),
      allAccounts: _sellPaymentEntries.map((e) => e.toRequestMap()).toList(),
      insideProducts: insideProducts,
      outsideProducts: outsideProducts,
      boxProducts: boxProducts,
      buyGoldProducts: _buyItems.map((item) => item.payload).toList(),
      deductionAccounts:
          _buyPaymentEntries.map((e) => e.toRequestMap()).toList(),
    );
    context.read<DoubleSellSubmitCubit>().submitSell(request);
  }

  String? _validateBeforeSubmit(double finalTotal) {
    if (_selectedClient == null) return 'common.pleaseChooseClient'.tr();
    if (_selectedWorker == null) return 'common.pleaseChooseWorker'.tr();
    if (_sellItems.isEmpty) {
      return 'gold_double_sell.addAtLeastOneSellItem'.tr();
    }
    if (_sellPaymentEntries.isEmpty) {
      return 'gold_double_sell.addAtLeastOneSellPayment'.tr();
    }
    if (_buyItems.isNotEmpty && _buyPaymentEntries.isEmpty) {
      return 'gold_double_sell.addDeductionAccount'.tr();
    }
    final hasMcDollarInside = _sellItems.any(
      (item) => item.type == 'inside' && (item.payload['is_mc_d'] == 1),
    );
    if (hasMcDollarInside && widget.preloadData.usdRate.usd <= 0) {
      return 'gold_double_sell.usdRateNotAvailable'.tr();
    }
    if (finalTotal <= 0) {
      return 'gold_double_sell.finalTotalMustBeGreater'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totals = DoubleSellPriceCalculator.calculateTotals(
      sellPrices: _sellItems.map((e) => e.price).toList(),
      buyPrices: _buyItems.map((e) => e.price).toList(),
      taxPercent: _taxPercent,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<ClientSearchCubit, ClientSearchState>(
          listener: (context, state) {
            state.whenOrNull(
              found: (client) => setState(() => _selectedClient = client),
              created: (client) {
                setState(() => _selectedClient = client);
                successSnackBar(
                  msg: 'common.clientCreated'.tr(),
                  context: context,
                );
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
                setState(() {
                  sellVendors = [
                    ...sellVendors,
                    GoldVendorModel(
                      id: vendor.id,
                      name: vendor.name,
                      caratId: vendor.caratId,
                      currencyId: vendor.currencyId,
                      gold: 0,
                      cash: 0,
                    ),
                  ];
                });
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
            constraints: const BoxConstraints(maxWidth: 1320),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;
                final formColumn = _buildFormColumn(totals);
                final summaryColumn = _DesktopSummaryPanel(
                  totals: totals,
                  taxController: _taxController,
                  notesController: _notesController,
                  onTaxChanged: () => setState(() {}),
                  onSubmit: () => _submit(totals.finalTotal),
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

  Widget _buildFormColumn(({double sellTotal, double buyTotal, double net, double taxAmount, double finalTotal}) totals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<ClientSearchCubit, ClientSearchState>(
            builder: (context, state) {
              return DoubleSellClientSection(
                searchController: _clientSearchController,
                state: state,
                selectedClient: _selectedClient,
                onSearch: () => context
                    .read<ClientSearchCubit>()
                    .searchClient(_clientSearchController.text),
                onOpenCreateClientSheet: _openCreateClientSheet,
                onClear: () {
                  setState(() => _selectedClient = null);
                  context.read<ClientSearchCubit>().clearClient();
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DoubleSellWorkerSelector(
            workers: widget.preloadData.workers,
            selectedWorker: _selectedWorker,
            onChanged: (worker) => setState(() => _selectedWorker = worker),
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'gold_double_sell.sellItems'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ProductLookupCubit, ProductLookupState>(
                builder: (context, productState) {
                  return DoubleSellItemTabs(
                    insideTab: DoubleSellInsideTab(
                      lookupState: productState,
                      productIdController: _insideProductIdController,
                      usdRate: widget.preloadData.usdRate.usd,
                      onLookup: () {
                        final id = int.tryParse(
                                _insideProductIdController.text.trim()) ??
                            0;
                        context.read<ProductLookupCubit>().lookupProduct(id);
                      },
                      onClearLookup: () =>
                          context.read<ProductLookupCubit>().clearLookup(),
                      onAddItem: (item) =>
                          setState(() => _sellItems.add(item)),
                    ),
                    boxTab: DoubleSellBoxTab(
                      carats: widget.preloadData.carats,
                      boxes: widget.preloadData.boxes,
                      vendors: List.of(sellVendors),
                      onCreateVendor: _openCreateVendorSheet,
                      onAddItem: (item) =>
                          setState(() => _sellItems.add(item)),
                    ),
                    outsideTab: BlocProvider(
                      create: (_) =>
                          GoldKindsCubit(getIt<GoldDoubleSellRepo>()),
                      child: DoubleSellOutsideTab(
                        carats: widget.preloadData.carats,
                        vendors: List.of(sellVendors),
                        onCreateVendor: _openCreateVendorSheet,
                        onAddItem: (item) =>
                            setState(() => _sellItems.add(item)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DoubleSellCartWidget(
            title: 'gold_double_sell.sellCart'.tr(),
            accentColor: _goldAccent,
            items: _sellItems,
            onRemove: (index) => setState(() => _sellItems.removeAt(index)),
            onPriceChanged: _updateSellItemPrice,
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DoubleSellPaymentSection(
            title: 'gold_double_sell.sellPaymentAccounts'.tr(),
            restAmountLabel: 'gold_double_sell.restOfSellCartTotal'.tr(),
            cartTotalAmount: totals.sellTotal,
            accentColor: _goldAccent,
            accounts: widget.preloadData.accounts,
            entries: _sellPaymentEntries,
            isRateEditable: true,
            onAdd: (entry) => setState(() => _sellPaymentEntries.add(entry)),
            onRemove: (index) =>
                setState(() => _sellPaymentEntries.removeAt(index)),
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'gold_double_sell.addBuyItems'.tr(),
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                    value: _showBuySection,
                    onChanged: (value) =>
                        setState(() => _showBuySection = value),
                  ),
                ],
              ),
              if (_showBuySection) ...[
                const SizedBox(height: 8),
                DoubleSellBuySection(
                  carats: widget.preloadData.carats,
                  boxes: widget.preloadData.boxes,
                  onAddItem: (item) => setState(() => _buyItems.add(item)),
                ),
              ],
            ],
          ),
        ),
        if (_buyItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          DesktopCard(
            padding: const EdgeInsets.all(16),
            child: DoubleSellCartWidget(
              title: 'gold_double_sell.buyCart'.tr(),
              accentColor: _buyAccent,
              items: _buyItems,
              onRemove: (index) => setState(() => _buyItems.removeAt(index)),
              onPriceChanged: _updateBuyItemPrice,
            ),
          ),
        ],
        if (_showBuySection || _buyItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          DesktopCard(
            padding: const EdgeInsets.all(16),
            child: DoubleSellPaymentSection(
              title: 'gold_double_sell.buyDeductionAccounts'.tr(),
              restAmountLabel: 'gold_double_sell.restOfBuyCartTotal'.tr(),
              cartTotalAmount: totals.buyTotal,
              accentColor: _buyAccent,
              accounts: widget.preloadData.accounts,
              entries: _buyPaymentEntries,
              isRateEditable: true,
              onAdd: (entry) =>
                  setState(() => _buyPaymentEntries.add(entry)),
              onRemove: (index) =>
                  setState(() => _buyPaymentEntries.removeAt(index)),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Sticky summary panel ──────────────────────────────────────────────────

class _DesktopSummaryPanel extends StatelessWidget {
  const _DesktopSummaryPanel({
    required this.totals,
    required this.taxController,
    required this.notesController,
    required this.onTaxChanged,
    required this.onSubmit,
  });

  final ({double sellTotal, double buyTotal, double net, double taxAmount, double finalTotal}) totals;
  final TextEditingController taxController;
  final TextEditingController notesController;
  final VoidCallback onTaxChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          DoubleSellSummaryWidget(
            sellTotal: totals.sellTotal,
            buyTotal: totals.buyTotal,
            net: totals.net,
            finalTotal: totals.finalTotal,
            taxController: taxController,
            onTaxChanged: (_) => onTaxChanged(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'common.notes'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
              'gold_double_sell.submitDoubleSell'.tr(),
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
