import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/platform/app_platform.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/hardware_scanner_header.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/diamond_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/models/stone_product_model.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_cubit.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/cubit/diamond_product_lookup_state.dart';
import 'package:kenooz_worker_app/features/diamond_sell/presentation/ui/widgets/diamond_sell_product_card.dart';

class DiamondSellProductScanner extends StatefulWidget {
  final double usdRate;
  final void Function(
    String type,
    DiamondProductModel? diamond,
    StoneProductModel? stone,
    double egpPrice,
  )
  onAddToCart;

  const DiamondSellProductScanner({
    super.key,
    required this.usdRate,
    required this.onAddToCart,
  });

  @override
  State<DiamondSellProductScanner> createState() =>
      _DiamondSellProductScannerState();
}

class _DiamondSellProductScannerState extends State<DiamondSellProductScanner> {
  final TextEditingController _idController = TextEditingController();
  String _selectedType = 'diamond';
  bool _autoAddPending = false;
  bool _autoAddLoadingSeen = false;
  int? _pendingProductId;
  String? _pendingProductType;
  int _lookupRequestId = 0;
  int? _activeLookupRequestId;

  /// Focus node for the product-ID field — autofocused on desktop and
  /// re-claimed after each scan so a hardware scanner can fire repeatedly.
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
    _idController.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }

  void _rearmScannerIfDesktop() {
    if (!AppPlatform.isDesktop) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _idFocusNode.requestFocus();
    });
  }

  void _searchAndAutoAdd() {
    final id = int.tryParse(_idController.text.trim()) ?? 0;
    if (id <= 0) {
      context.read<DiamondProductLookupCubit>().lookupProduct(
        _selectedType,
        id,
      );
      return;
    }

    context.read<DiamondProductLookupCubit>().clearLookup();
    setState(() {
      _autoAddPending = true;
      _autoAddLoadingSeen = false;
      _pendingProductId = id;
      _pendingProductType = _selectedType;
      _lookupRequestId++;
      _activeLookupRequestId = _lookupRequestId;
    });

    context.read<DiamondProductLookupCubit>().lookupProduct(_selectedType, id);
  }

  void _clearPendingAutoAdd() {
    _autoAddPending = false;
    _autoAddLoadingSeen = false;
    _pendingProductId = null;
    _pendingProductType = null;
    _activeLookupRequestId = null;
  }

  void _completeAutoAdd() {
    _idController.clear();
    context.read<DiamondProductLookupCubit>().clearLookup();
    setState(_clearPendingAutoAdd);
    _rearmScannerIfDesktop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const diamondAccent = Color(0xFF64B5F6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : diamondAccent.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'diamond_sell.scanProduct'.tr(),
            style: AppFonts.heading(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 10.h),
          // Type toggle
          Row(
            children: [
              _TypeChip(
                label: 'diamond_sell.diamond'.tr(),
                icon: Icons.diamond_rounded,
                isSelected: _selectedType == 'diamond',
                selectedColor: diamondAccent,
                onTap: () => setState(() => _selectedType = 'diamond'),
              ),
              SizedBox(width: 8.w),
              _TypeChip(
                label: 'diamond_sell.stone'.tr(),
                icon: Icons.hexagon_rounded,
                isSelected: _selectedType == 'stone',
                selectedColor: Colors.purple,
                onTap: () => setState(() => _selectedType = 'stone'),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (AppPlatform.isDesktop)
            HardwareScannerHeader(focusNode: _idFocusNode, isDark: isDark),
          // ID input + search button
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _idController,
                  focusNode: _idFocusNode,
                  autofocus: AppPlatform.isDesktop,
                  hintText: 'diamond_sell.enterProductId'.tr(),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _searchAndAutoAdd(),
                  height: 66.h,
                  borderRadius: BorderRadius.circular(12.r),
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.darkBrown.withOpacity(0.1),
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.04)
                      : AppColors.backGroundColorLight,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 46.h,
                child: ElevatedButton(
                  onPressed: _searchAndAutoAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('common.search'.tr()),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Product lookup result
          BlocBuilder<DiamondProductLookupCubit, DiamondProductLookupState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Builder(
                    builder: (_) {
                      if (_autoAddPending) {
                        _autoAddLoadingSeen = true;
                      }
                      return const LinearProgressIndicator(minHeight: 2);
                    },
                  ),
                ),
                foundDiamond: (product) {
                  final egp = product.total * widget.usdRate;
                  final shouldAutoAdd =
                      _autoAddPending &&
                      _autoAddLoadingSeen &&
                      _pendingProductType == 'diamond' &&
                      _pendingProductId == product.id &&
                      _activeLookupRequestId != null;

                  if (shouldAutoAdd) {
                    final requestId = _activeLookupRequestId!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      final stillSameRequest =
                          _activeLookupRequestId == requestId &&
                          _autoAddPending &&
                          _pendingProductType == 'diamond' &&
                          _pendingProductId == product.id;
                      if (!stillSameRequest) return;
                      widget.onAddToCart('diamond', product, null, egp);
                      _completeAutoAdd();
                    });
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: DiamondSellProductCard(
                      productType: 'diamond',
                      diamond: product,
                      egpPrice: egp,
                    ),
                  );
                },
                foundStone: (product) {
                  final egp = product.price * widget.usdRate;
                  final shouldAutoAdd =
                      _autoAddPending &&
                      _autoAddLoadingSeen &&
                      _pendingProductType == 'stone' &&
                      _pendingProductId == product.id &&
                      _activeLookupRequestId != null;

                  if (shouldAutoAdd) {
                    final requestId = _activeLookupRequestId!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      final stillSameRequest =
                          _activeLookupRequestId == requestId &&
                          _autoAddPending &&
                          _pendingProductType == 'stone' &&
                          _pendingProductId == product.id;
                      if (!stillSameRequest) return;
                      widget.onAddToCart('stone', null, product, egp);
                      _completeAutoAdd();
                    });
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: DiamondSellProductCard(
                      productType: 'stone',
                      stone: product,
                      egpPrice: egp,
                    ),
                  );
                },
                notFound: () {
                  _clearPendingAutoAdd();
                  return _statusRow(
                    Icons.info_outline_rounded,
                    'diamond_sell.productNotFoundOrWrongShop'.tr(),
                    AppColors.errorColor,
                  );
                },
                alreadySold: () {
                  _clearPendingAutoAdd();
                  return _statusRow(
                    Icons.block_rounded,
                    'diamond_sell.productAlreadySold'.tr(),
                    AppColors.errorColor,
                  );
                },
                invalidType: () {
                  _clearPendingAutoAdd();
                  return _statusRow(
                    Icons.warning_amber_rounded,
                    'diamond_sell.selectDiamondOrStone'.tr(),
                    AppColors.errorColor,
                  );
                },
                error: (messages) {
                  _clearPendingAutoAdd();
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      messages.join('\n'),
                      style: AppFonts.body(
                        fontSize: 12.sp,
                        color: AppColors.errorColor,
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusRow(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppFonts.body(fontSize: 12.sp, color: color),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.15)
              : isDark
              ? Colors.white.withOpacity(0.04)
              : AppColors.backGroundColorLight,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.darkBrown.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected
                  ? selectedColor
                  : isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? selectedColor
                    : isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
