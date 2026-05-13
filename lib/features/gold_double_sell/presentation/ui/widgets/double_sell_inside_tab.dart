import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/services/toast_service.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/hardware_scanner_header.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/helpers/price_calculator.dart';
import 'package:kenooz_worker_app/core/platform/app_platform.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/product_lookup_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_product_card.dart';

class DoubleSellInsideTab extends StatefulWidget {
  final ProductLookupState lookupState;
  final TextEditingController productIdController;
  final double usdRate;
  final VoidCallback onLookup;
  final VoidCallback onClearLookup;
  final ValueChanged<DoubleSellCartItemModel> onAddItem;

  const DoubleSellInsideTab({
    super.key,
    required this.lookupState,
    required this.productIdController,
    required this.usdRate,
    required this.onLookup,
    required this.onClearLookup,
    required this.onAddItem,
  });

  @override
  State<DoubleSellInsideTab> createState() => _DoubleSellInsideTabState();
}

class _DoubleSellInsideTabState extends State<DoubleSellInsideTab> {
  bool _autoAddPending = false;
  bool _autoAddLoadingSeen = false;
  int? _pendingProductId;
  int _lookupRequestId = 0;
  int? _activeLookupRequestId;

  /// Focus node for the product-ID field. On desktop we keep it autofocused
  /// and re-claim focus after each scan so a USB/Bluetooth barcode scanner
  /// can fire repeatedly without the user clicking.
  final FocusNode _idFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (AppPlatform.isDesktop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _idFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _idFocusNode.dispose();
    super.dispose();
  }

  void _rearmScannerIfDesktop() {
    if (!AppPlatform.isDesktop) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _idFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (AppPlatform.isDesktop)
          HardwareScannerHeader(focusNode: _idFocusNode, isDark: isDark),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: widget.productIdController,
                focusNode: _idFocusNode,
                autofocus: AppPlatform.isDesktop,
                labelText: 'common.productId'.tr(),
                keyboardType: TextInputType.number,
                height: 66.h,
                borderRadius: BorderRadius.circular(12.r),
                borderColor: isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.darkBrown.withOpacity(0.1),
                fillColor: isDark
                    ? Colors.white.withOpacity(0.04)
                    : AppColors.backGroundColorLight,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _triggerLookupAndAutoAdd(),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              height: 46.h,
              child: ElevatedButton(
                onPressed: _triggerLookupAndAutoAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text('common.lookup'.tr()),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        widget.lookupState.maybeWhen(
          loading: () {
            if (_autoAddPending) {
              _autoAddLoadingSeen = true;
            }
            return const LinearProgressIndicator(minHeight: 2);
          },
          notFound: () {
            _clearPendingAutoAdd();
            return _message('common.productNotFound'.tr(), AppColors.errorColor);
          },
          alreadySold: () {
            _clearPendingAutoAdd();
            return _message(
              'common.productAlreadySold'.tr(),
              AppColors.errorColor,
            );
          },
          error: (messages) {
            _clearPendingAutoAdd();
            return _message(messages.join('\n'), AppColors.errorColor);
          },
          found: (product) {
            final price = DoubleSellPriceCalculator.insidePrice(
              mc: product.mc,
              gramPrice: product.gramPrice,
              profit: product.profit,
              grams: product.grams,
              isMcDollar: product.isMcD,
              usdRate: widget.usdRate,
            );

            final shouldAutoAdd =
                _autoAddPending &&
                _autoAddLoadingSeen &&
                _pendingProductId == product.id &&
                _activeLookupRequestId != null;

            if (shouldAutoAdd) {
              final requestId = _activeLookupRequestId!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final stillSameRequest =
                    _activeLookupRequestId == requestId &&
                    _autoAddPending &&
                    _pendingProductId == product.id;
                if (!stillSameRequest) return;
                _addProductToCart(product, price);
              });
            }

            return DoubleSellProductCard(product: product, price: price);
          },
          orElse: () => _message(
            'gold_double_sell.scanOrEnterProductId'.tr(),
            isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
          ),
        ),
      ],
    );
  }

  void _triggerLookupAndAutoAdd() {
    final rawId = widget.productIdController.text.trim();
    if (rawId.isEmpty) {
      _showToast('common.pleaseEnterProductId'.tr());
      return;
    }

    final parsedId = int.tryParse(rawId);
    if (parsedId == null || parsedId <= 0) {
      _showToast('common.pleaseEnterValidId'.tr());
      return;
    }

    widget.onClearLookup();
    setState(() {
      _autoAddPending = true;
      _autoAddLoadingSeen = false;
      _pendingProductId = parsedId;
      _lookupRequestId++;
      _activeLookupRequestId = _lookupRequestId;
    });
    widget.onLookup();
  }

  void _addProductToCart(dynamic product, double price) {
    final finalProfit = product.profit;
    final finalPrice = price;

    widget.onAddItem(
      DoubleSellCartItemModel(
        key: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'inside',
        title: product.name,
        subtitle: 'Inside • ${product.caratName}',
        grams: product.grams,
        price: finalPrice,
        payload: {
          'id': product.id,
          'grams': product.grams,
          'mc': product.mc,
          'gram_price': product.gramPrice,
          'is_mc_d': product.isMcD ? 1 : 0,
          'profit': finalProfit,
          'price': finalPrice,
        },
      ),
    );

    widget.productIdController.clear();
    widget.onClearLookup();
    _showToast('common.addedToSellCart'.tr());
    setState(_clearPendingAutoAdd);
    _rearmScannerIfDesktop();
  }

  void _clearPendingAutoAdd() {
    _autoAddPending = false;
    _autoAddLoadingSeen = false;
    _pendingProductId = null;
    _activeLookupRequestId = null;
  }

  void _showToast(String message) {
    ToastService.show(message);
  }

  Widget _message(String message, Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        message,
        style: AppFonts.body(fontSize: 12.sp, color: color),
      ),
    );
  }
}
