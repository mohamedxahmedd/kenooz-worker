import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/services/toast_service.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/helpers/price_calculator.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_carat_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_kind_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/models/gold_vendor_model.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_kinds_cubit.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/cubit/gold_kinds_state.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart';

class DoubleSellOutsideTab extends StatefulWidget {
  final List<GoldCaratModel> carats;
  final List<GoldVendorModel> vendors;
  final ValueChanged<DoubleSellCartItemModel> onAddItem;
  final VoidCallback onCreateVendor;

  const DoubleSellOutsideTab({
    super.key,
    required this.carats,
    required this.vendors,
    required this.onAddItem,
    required this.onCreateVendor,
  });

  @override
  State<DoubleSellOutsideTab> createState() => _DoubleSellOutsideTabState();
}

class _DoubleSellOutsideTabState extends State<DoubleSellOutsideTab> {
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _mcController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _gramPriceController = TextEditingController();

  GoldCaratModel? _selectedCarat;
  GoldKindModel? _selectedKind;
  GoldVendorModel? _selectedVendor;
  List<GoldKindModel> _kinds = [];

  @override
  void initState() {
    super.initState();
    _mcController.text = '0';
    _profitController.text = '0';
    if (widget.carats.isNotEmpty) {
      _selectedCarat = widget.carats.first;
      _gramPriceController.text = _selectedCarat!.price.toStringAsFixed(2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GoldKindsCubit>().fetchKinds(_selectedCarat!.id);
      });
    }
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _mcController.dispose();
    _profitController.dispose();
    _gramPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<GoldKindsCubit, GoldKindsState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (kinds) {
            setState(() {
              _kinds = kinds;
              _selectedKind = kinds.isNotEmpty ? kinds.first : null;
            });
          },
        );
      },
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<GoldVendorModel>(
                  isExpanded: true,
                  value: _selectedVendor,
                  decoration: _inputDecoration('common.vendor'.tr(), isDark),
                  items: widget.vendors
                      .map(
                        (vendor) => DropdownMenuItem(
                          value: vendor,
                          child: Text(
                            vendor.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedVendor = value),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: IconButton(
                  onPressed: widget.onCreateVendor,
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.darkBrown,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<GoldCaratModel>(
                  isExpanded: true,
                  value: _selectedCarat,
                  decoration: _inputDecoration('common.carat'.tr(), isDark),
                  items: widget.carats
                      .map(
                        (carat) => DropdownMenuItem(
                          value: carat,
                          child: Text(carat.carat),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCarat = value;
                      _selectedKind = null;
                      _gramPriceController.text = value.price.toStringAsFixed(
                        2,
                      );
                    });
                    context.read<GoldKindsCubit>().fetchKinds(value.id);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: DropdownButtonFormField<GoldKindModel>(
                  isExpanded: true,
                  value: _selectedKind,
                  decoration: _inputDecoration('common.kind'.tr(), isDark),
                  items: _kinds
                      .map(
                        (kind) => DropdownMenuItem(
                          value: kind,
                          child: Text(
                            kind.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedKind = value),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _numberField(_gramsController, 'common.grams'.tr(), isDark)),
              SizedBox(width: 8.w),
              Expanded(
                child: _numberField(_gramPriceController, 'common.gramPrice'.tr(), isDark),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _numberField(_mcController, 'common.mc'.tr(), isDark)),
              SizedBox(width: 8.w),
              Expanded(
                child: _numberField(_profitController, 'common.profit'.tr(), isDark),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('gold_double_sell.addOutsideItem'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    bool isDark,
  ) {
    return CustomTextFormField(
      controller: controller,
      labelText: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      height: 66.h,
      borderRadius: BorderRadius.circular(12.r),
      borderColor: isDark
          ? Colors.white.withOpacity(0.08)
          : AppColors.darkBrown.withOpacity(0.1),
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
    );
  }

  void _addItem() {
    final carat = _selectedCarat;
    final kind = _selectedKind;
    final vendor = _selectedVendor;

    if (carat == null) {
      _showToast('common.pleaseSelectCarat'.tr());
      return;
    }
    if (kind == null) {
      _showToast('common.pleaseSelectKind'.tr());
      return;
    }
    if (vendor == null) {
      _showToast('common.pleaseSelectVendor'.tr());
      return;
    }
    if (_gramsController.text.trim().isEmpty) {
      _showToast('common.pleaseEnterGrams'.tr());
      return;
    }
    if (_gramPriceController.text.trim().isEmpty) {
      _showToast('common.pleaseEnterGramPrice'.tr());
      return;
    }
    if (_mcController.text.trim().isEmpty) {
      _showToast('common.pleaseEnterMC'.tr());
      return;
    }
    if (_profitController.text.trim().isEmpty) {
      _showToast('common.pleaseEnterProfit'.tr());
      return;
    }

    final grams = double.tryParse(_gramsController.text.trim());
    final gramPrice = double.tryParse(_gramPriceController.text.trim());
    final mc = double.tryParse(_mcController.text.trim());
    final profit = double.tryParse(_profitController.text.trim());

    if (grams == null || grams <= 0) {
      _showToast('common.pleaseEnterValidGrams'.tr());
      return;
    }
    if (gramPrice == null || gramPrice <= 0) {
      _showToast('common.pleaseEnterValidGramPrice'.tr());
      return;
    }
    if (mc == null || mc < 0) {
      _showToast('common.pleaseEnterValidMC'.tr());
      return;
    }
    if (profit == null || profit < 0) {
      _showToast('common.pleaseEnterValidProfit'.tr());
      return;
    }

    final price = DoubleSellPriceCalculator.outsidePrice(
      grams: grams,
      gramPrice: gramPrice,
      mc: mc,
      profit: profit,
    );

    widget.onAddItem(
      DoubleSellCartItemModel(
        key: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'outside',
        title: '${kind.name} • ${carat.carat}',
        subtitle: 'Outside',
        grams: grams,
        price: price,
        payload: {
          'carat_id': carat.id,
          'kind_id': kind.id,
          'vendor_id': vendor.id,
          'grams': grams,
          'gram_price': gramPrice,
          'mc': mc,
          'profit': profit,
          'price': price,
        },
      ),
    );

    _gramsController.clear();
    _mcController.text = '0';
    _profitController.text = '0';
  }

  void _showToast(String message) {
    ToastService.show(message);
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : AppColors.backGroundColorLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.darkBrown.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.darkBrown),
      ),
    );
  }
}
