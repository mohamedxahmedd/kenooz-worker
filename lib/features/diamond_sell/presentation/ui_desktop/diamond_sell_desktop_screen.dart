import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_preload_data.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_sell_request_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_client_search_state.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_preload_state.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_sell_submit_state.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_client_section.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_product_scanner.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_summary_widget.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/client_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/create_client_request_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_widget.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_create_client_sheet.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_payment_section.dart';

const Color _diamondAccent = Color(0xFF64B5F6);

/// Desktop Diamond Sell. Uses every existing diamond_sell sub-widget
/// (client section, product scanner with diamond/stone toggle, cart,
/// payment section, summary) inside a desktop chrome with a sticky
/// summary + submit panel on the right. All validation rules and the
/// submit payload structure are preserved exactly.
class DiamondSellDesktopScreen extends StatefulWidget {
  const DiamondSellDesktopScreen({super.key});

  @override
  State<DiamondSellDesktopScreen> createState() =>
      _DiamondSellDesktopScreenState();
}

class _DiamondSellDesktopScreenState extends State<DiamondSellDesktopScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DiamondSellPreloadCubit>().fetchPreloadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DiamondSellSubmitCubit, DiamondSellSubmitState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => EasyLoading.show(),
          success: (data) {
            EasyLoading.dismiss();
            successSnackBar(
              msg:
                  '${'diamond_sell.submitSuccess'.tr()} #${data.unifiedId} • ${data.grandTotal.toStringAsFixed(2)} ${'common.egp'.tr()}',
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
              child: BlocBuilder<DiamondSellPreloadCubit,
                  DiamondSellPreloadState>(
                builder: (context, state) => state.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (messages) => _DesktopError(
                    message: messages.join('\n'),
                    onRetry: () => context
                        .read<DiamondSellPreloadCubit>()
                        .fetchPreloadData(),
                  ),
                  success: (data) =>
                      _DiamondSellDesktopFormView(preloadData: data),
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
              backgroundColor: _diamondAccent.withValues(alpha: 0.18),
              child: const Icon(Icons.diamond_outlined, color: _diamondAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'diamond_sell.title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'diamond_sell.subtitle'.tr(),
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

class _DiamondSellDesktopFormView extends StatefulWidget {
  const _DiamondSellDesktopFormView({required this.preloadData});
  final DiamondSellPreloadData preloadData;

  @override
  State<_DiamondSellDesktopFormView> createState() =>
      _DiamondSellDesktopFormViewState();
}

class _DiamondSellDesktopFormViewState
    extends State<_DiamondSellDesktopFormView> {
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  ClientModel? _selectedClient;
  final List<DoubleSellCartItemModel> _cartItems = [];
  final List<DoubleSellPaymentEntry> _paymentEntries = [];

  @override
  void dispose() {
    _clientSearchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _grandTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.price);

  int get _diamondCount => _cartItems.where((e) => e.type == 'diamond').length;
  int get _stoneCount => _cartItems.where((e) => e.type == 'stone').length;

  double get _diamondTotal => _cartItems
      .where((e) => e.type == 'diamond')
      .fold(0.0, (sum, item) => sum + item.price);

  double get _stoneTotal => _cartItems
      .where((e) => e.type == 'stone')
      .fold(0.0, (sum, item) => sum + item.price);

  double get _totalPaid =>
      _paymentEntries.fold(0.0, (sum, entry) => sum + entry.cash);

  void _onAddToCart(
    String type,
    DiamondProductModel? diamond,
    StoneProductModel? stone,
    double egpPrice,
  ) {
    if (type == 'diamond' && diamond != null) {
      _cartItems.add(
        DoubleSellCartItemModel(
          key: 'diamond_${diamond.id}',
          type: 'diamond',
          title: diamond.name,
          subtitle:
              'Diamond: ${diamond.totalDWeight.toStringAsFixed(3)} ct  •  Gold: ${diamond.totalGWeight.toStringAsFixed(3)} g',
          grams: diamond.totalWeight,
          price: egpPrice,
          payload: {
            'pro_id': diamond.id,
            'product_type': 'diamond',
            'usd_price': diamond.total,
          },
        ),
      );
    } else if (type == 'stone' && stone != null) {
      _cartItems.add(
        DoubleSellCartItemModel(
          key: 'stone_${stone.id}',
          type: 'stone',
          title: stone.name,
          subtitle:
              'Weight: ${stone.weight.toStringAsFixed(2)} ct  •  Report: ${stone.reportNumber}',
          grams: stone.weight,
          price: egpPrice,
          payload: {
            'pro_id': stone.id,
            'product_type': 'stone',
            'usd_price': stone.price,
          },
        ),
      );
    }
    setState(() {});
  }

  void _updateCartItemPrice(int index, double newPrice) {
    if (index < 0 || index >= _cartItems.length) return;
    if (newPrice <= 0) return;
    final currentItem = _cartItems[index];
    if ((newPrice - currentItem.price).abs() < 0.0001) return;
    setState(() {
      _cartItems[index] = currentItem.copyWith(price: newPrice);
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
    context.read<DiamondClientSearchCubit>().createClient(request);
  }

  void _submit() {
    final validationMessage = _validateBeforeSubmit();
    if (validationMessage != null) {
      failureSnackBar(msg: validationMessage, context: context);
      return;
    }

    final products = _cartItems.map((item) {
      final proId = item.payload['pro_id'] as int;
      final productType = item.payload['product_type'] as String;
      if (productType == 'diamond') {
        return {
          'type': 'diamond',
          'pro_id': proId,
          'product_price': item.price,
        };
      } else {
        return {'type': 'stone', 'pro_id': proId, 'price': item.price};
      }
    }).toList();

    final workerId = CacheHelper.getData(key: CacheKeys.userId) as int? ?? 0;

    final request = DiamondSellRequestModel(
      clientId: _selectedClient!.id,
      workerId: workerId,
      total: _grandTotal,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      products: products,
      allAccounts: _paymentEntries
          .where((e) => e.cash > 0)
          .map((e) => e.toRequestMap())
          .toList(),
    );

    context.read<DiamondSellSubmitCubit>().submitSell(request);
  }

  String? _validateBeforeSubmit() {
    if (_selectedClient == null) return 'common.pleaseChooseClient'.tr();
    if (_cartItems.isEmpty) return 'common.addAtLeastOneProductToCart'.tr();

    final seenKeys = <String>{};
    for (final item in _cartItems) {
      final proId = item.payload['pro_id'] as int;
      final productType = item.payload['product_type'] as String;
      final key = '$productType:$proId';
      if (seenKeys.contains(key)) {
        return 'common.duplicateProductInCart'.tr();
      }
      seenKeys.add(key);
    }

    if (_paymentEntries.isEmpty) {
      return 'common.addAtLeastOnePaymentAccount'.tr();
    }

    final paymentTotal = _paymentEntries.fold(
      0.0,
      (sum, entry) => sum + entry.cash,
    );
    if ((paymentTotal - _grandTotal).abs() > 0.01) {
      return 'diamond_sell.paymentTotalMismatch'.tr();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DiamondClientSearchCubit, DiamondClientSearchState>(
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
                  grandTotal: _grandTotal,
                  totalPaid: _totalPaid,
                  diamondCount: _diamondCount,
                  stoneCount: _stoneCount,
                  diamondTotal: _diamondTotal,
                  stoneTotal: _stoneTotal,
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
          child:
              BlocBuilder<DiamondClientSearchCubit, DiamondClientSearchState>(
            builder: (context, state) {
              return DiamondSellClientSection(
                searchController: _clientSearchController,
                state: state,
                selectedClient: _selectedClient,
                onSearch: () => context
                    .read<DiamondClientSearchCubit>()
                    .searchClient(_clientSearchController.text),
                onOpenCreateClientSheet: _openCreateClientSheet,
                onClear: () {
                  setState(() => _selectedClient = null);
                  context.read<DiamondClientSearchCubit>().clearClient();
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DiamondSellProductScanner(
            usdRate: widget.preloadData.usdRate.usd,
            onAddToCart: _onAddToCart,
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DoubleSellCartWidget(
            title: 'common.cart'.tr(),
            accentColor: _diamondAccent,
            items: _cartItems,
            onRemove: (index) => setState(() => _cartItems.removeAt(index)),
            onPriceChanged: _updateCartItemPrice,
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DoubleSellPaymentSection(
            title: 'common.paymentAccounts'.tr(),
            restAmountLabel: 'common.restOfSellCartTotal'.tr(),
            cartTotalAmount: _grandTotal,
            accentColor: _diamondAccent,
            accounts: widget.preloadData.accounts,
            entries: _paymentEntries,
            isRateEditable: true,
            onAdd: (entry) => setState(() => _paymentEntries.add(entry)),
            onRemove: (index) =>
                setState(() => _paymentEntries.removeAt(index)),
          ),
        ),
        const SizedBox(height: 12),
        DesktopCard(
          padding: const EdgeInsets.all(16),
          child: DiamondSellSummaryWidget(
            diamondCount: _diamondCount,
            stoneCount: _stoneCount,
            diamondTotal: _diamondTotal,
            stoneTotal: _stoneTotal,
            grandTotal: _grandTotal,
            notesController: _notesController,
          ),
        ),
      ],
    );
  }
}

class _DesktopSummaryPanel extends StatelessWidget {
  const _DesktopSummaryPanel({
    required this.grandTotal,
    required this.totalPaid,
    required this.diamondCount,
    required this.stoneCount,
    required this.diamondTotal,
    required this.stoneTotal,
    required this.onSubmit,
  });

  final double grandTotal;
  final double totalPaid;
  final int diamondCount;
  final int stoneCount;
  final double diamondTotal;
  final double stoneTotal;
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
              const Icon(Icons.summarize_outlined, color: _diamondAccent),
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
            label: 'common.diamondColumn'.tr(),
            value: diamondTotal,
            suffix: ' ($diamondCount)',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'common.stoneColumn'.tr(),
            value: stoneTotal,
            suffix: ' ($stoneCount)',
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'common.total'.tr(),
            value: grandTotal,
            emphasize: true,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'gold_buy.totalPaid'.tr(),
            value: totalPaid,
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _diamondAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onSubmit,
            child: Text(
              'diamond_sell.submitDiamondSell'.tr(),
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
    this.suffix = '',
  });
  final String label;
  final double value;
  final bool emphasize;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '$label$suffix',
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
            color: emphasize ? _diamondAccent : theme.colorScheme.onSurface,
          ),
        ),
      ],
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
