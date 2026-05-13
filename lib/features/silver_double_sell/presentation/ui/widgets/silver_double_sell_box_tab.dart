import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/services/toast_service.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_text_form_field.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/presentation/ui/widgets/double_sell_cart_item_card.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/helpers/silver_price_calculator.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_box_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_carat_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_kind_model.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/models/silver_vendor_model.dart';

class SilverDoubleSellBoxTab extends StatefulWidget {
  final List<SilverCaratModel> carats;
  final List<SilverKindModel> kinds;
  final List<SilverBoxModel> boxes;
  final List<SilverVendorModel> vendors;
  final ValueChanged<DoubleSellCartItemModel> onAddItem;
  final VoidCallback onCreateVendor;

  const SilverDoubleSellBoxTab({
    super.key,
    required this.carats,
    required this.kinds,
    required this.boxes,
    required this.vendors,
    required this.onAddItem,
    required this.onCreateVendor,
  });

  @override
  State<SilverDoubleSellBoxTab> createState() => _SilverDoubleSellBoxTabState();
}

class _SilverDoubleSellBoxTabState extends State<SilverDoubleSellBoxTab> {
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _mcController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _gramPriceController = TextEditingController();

  SilverCaratModel? _selectedCarat;
  SilverKindModel? _selectedKind;
  SilverBoxModel? _selectedBox;
  SilverVendorModel? _selectedVendor;

  @override
  void initState() {
    super.initState();
    _lossController.text = '0';
    if (widget.carats.isNotEmpty) {
      _selectedCarat = widget.carats.first;
      _gramPriceController.text = _selectedCarat!.price.toStringAsFixed(2);
    }
    if (widget.kinds.isNotEmpty) {
      _selectedKind = widget.kinds.first;
    }
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _lossController.dispose();
    _mcController.dispose();
    _profitController.dispose();
    _gramPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SilverCaratModel>(
                isExpanded: true,
                value: _selectedCarat,
                decoration: _inputDecoration('common.carat'.tr(), isDark),
                items: widget.carats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.carat)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCarat = value;
                    _gramPriceController.text = value.price.toStringAsFixed(2);
                  });
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: DropdownButtonFormField<SilverKindModel>(
                isExpanded: true,
                value: _selectedKind,
                decoration: _inputDecoration('common.kind'.tr(), isDark),
                items: widget.kinds
                    .map((k) => DropdownMenuItem(
                          value: k,
                          child: Text(k.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedKind = value),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SilverBoxModel>(
                isExpanded: true,
                value: _selectedBox,
                decoration: _inputDecoration('common.box'.tr(), isDark),
                items: widget.boxes
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBox = value),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: DropdownButtonFormField<SilverVendorModel>(
                isExpanded: true,
                value: _selectedVendor,
                decoration: _inputDecoration('common.vendor'.tr(), isDark),
                items: widget.vendors
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedVendor = value),
              ),
            ),
            SizedBox(width: 6.w),
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: IconButton(
                onPressed: widget.onCreateVendor,
                icon: Icon(Icons.person_add_alt_1_rounded, color: AppColors.darkBrown, size: 20.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: _numberField(_gramsController, 'common.grams'.tr(), isDark)),
            SizedBox(width: 8.w),
            Expanded(child: _numberField(_gramPriceController, 'common.gramPrice'.tr(), isDark)),
          ],
        ),
        SizedBox(height: 8.h),
        _numberField(_lossController, 'common.loss'.tr(), isDark),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: _numberField(_mcController, 'common.mc'.tr(), isDark)),
            SizedBox(width: 8.w),
            Expanded(child: _numberField(_profitController, 'common.profit'.tr(), isDark)),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9E9E9E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text('gold_double_sell.addBoxItem'.tr()),
          ),
        ),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, String label, bool isDark) {
    return CustomTextFormField(
      controller: controller,
      labelText: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      height: 66.h,
      borderRadius: BorderRadius.circular(12.r),
      borderColor: isDark ? Colors.white.withOpacity(0.08) : AppColors.darkBrown.withOpacity(0.1),
      fillColor: isDark ? Colors.white.withOpacity(0.04) : AppColors.backGroundColorLight,
    );
  }

  void _addItem() {
    final carat = _selectedCarat;
    final kind = _selectedKind;
    final box = _selectedBox;
    final vendor = _selectedVendor;

    if (carat == null) { _showToast('common.pleaseSelectCarat'.tr()); return; }
    if (kind == null) { _showToast('common.pleaseSelectKind'.tr()); return; }
    if (box == null) { _showToast('common.pleaseSelectBox'.tr()); return; }
    if (vendor == null) { _showToast('common.pleaseSelectVendor'.tr()); return; }
    if (_gramsController.text.trim().isEmpty) { _showToast('common.pleaseEnterGrams'.tr()); return; }
    if (_lossController.text.trim().isEmpty) _lossController.text = '0';
    if (_gramPriceController.text.trim().isEmpty) { _showToast('common.pleaseEnterGramPrice'.tr()); return; }
    if (_mcController.text.trim().isEmpty) { _showToast('common.pleaseEnterMc'.tr()); return; }
    if (_profitController.text.trim().isEmpty) { _showToast('common.pleaseEnterProfit'.tr()); return; }

    final grams = double.tryParse(_gramsController.text.trim());
    final loss = double.tryParse(_lossController.text.trim());
    final gramPrice = double.tryParse(_gramPriceController.text.trim());
    final mc = double.tryParse(_mcController.text.trim());
    final profit = double.tryParse(_profitController.text.trim());

    if (grams == null || grams <= 0) { _showToast('common.pleaseEnterValidGrams'.tr()); return; }
    if (loss == null || loss < 0) { _showToast('common.pleaseEnterValidLoss'.tr()); return; }
    if (gramPrice == null || gramPrice <= 0) { _showToast('common.pleaseEnterValidGramPrice'.tr()); return; }
    if (mc == null || mc < 0) { _showToast('common.pleaseEnterValidMc'.tr()); return; }
    if (profit == null || profit < 0) { _showToast('common.pleaseEnterValidProfit'.tr()); return; }

    final price = SilverDoubleSellPriceCalculator.boxPrice(
      grams: grams,
      loss: loss,
      gramPrice: gramPrice,
      mc: mc,
      profit: profit,
    );

    widget.onAddItem(
      DoubleSellCartItemModel(
        key: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'box',
        title: '${kind.name} • ${carat.carat}',
        subtitle: '${'silver_double_sell.box'.tr()}: ${box.name}',
        grams: grams,
        price: price,
        payload: {
          'carat_id': carat.id,
          'kind_id': kind.id,
          'box_id': box.id,
          'vendor_id': vendor.id,
          'grams': grams,
          'loss': loss,
          'gram_price': gramPrice,
          'mc': mc,
          'profit': profit,
          'price': price,
        },
      ),
    );

    _gramsController.clear();
    _lossController.text = '0';
    _mcController.clear();
    _profitController.clear();
  }

  void _showToast(String message) {
    ToastService.show(message);
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.04) : AppColors.backGroundColorLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : AppColors.darkBrown.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.darkBrown),
      ),
    );
  }
}
