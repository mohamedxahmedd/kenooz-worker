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

class SilverDoubleSellBuySection extends StatefulWidget {
  final List<SilverCaratModel> carats;
  final List<SilverBoxModel> boxes;
  final ValueChanged<DoubleSellCartItemModel> onAddItem;

  const SilverDoubleSellBuySection({
    super.key,
    required this.carats,
    required this.boxes,
    required this.onAddItem,
  });

  @override
  State<SilverDoubleSellBuySection> createState() => _SilverDoubleSellBuySectionState();
}

class _SilverDoubleSellBuySectionState extends State<SilverDoubleSellBuySection> {
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _gramPriceController = TextEditingController();

  SilverCaratModel? _selectedCarat;
  SilverBoxModel? _selectedBox;

  @override
  void initState() {
    super.initState();
    _lossController.text = '0';
    if (widget.carats.isNotEmpty) {
      _selectedCarat = widget.carats.first;
      // Silver buy gram price default = carat.price - 50
      final buyDefault = _selectedCarat!.price - 50;
      _gramPriceController.text = buyDefault > 0 ? buyDefault.toStringAsFixed(2) : '0';
    }
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _lossController.dispose();
    _gramPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.successColor.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<SilverCaratModel>(
            value: _selectedCarat,
            decoration: _inputDecoration('common.carat'.tr(), isDark),
            items: widget.carats
                .map((c) => DropdownMenuItem(value: c, child: Text(c.carat)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedCarat = value;
                final buyDefault = value.price - 50;
                _gramPriceController.text = buyDefault > 0
                    ? buyDefault.toStringAsFixed(2)
                    : '0';
              });
            },
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<SilverBoxModel>(
            value: _selectedBox,
            decoration: _inputDecoration('common.box'.tr(), isDark),
            items: widget.boxes
                .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedBox = value),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('gold_double_sell.addBuyItem'.tr()),
            ),
          ),
        ],
      ),
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
    final box = _selectedBox;

    if (carat == null) { _showToast('common.pleaseSelectCarat'.tr()); return; }
    if (box == null) { _showToast('common.pleaseSelectBox'.tr()); return; }
    if (_gramsController.text.trim().isEmpty) { _showToast('common.pleaseEnterGrams'.tr()); return; }
    if (_lossController.text.trim().isEmpty) _lossController.text = '0';
    if (_gramPriceController.text.trim().isEmpty) { _showToast('common.pleaseEnterGramPrice'.tr()); return; }

    final grams = double.tryParse(_gramsController.text.trim());
    final loss = double.tryParse(_lossController.text.trim());
    final gramPrice = double.tryParse(_gramPriceController.text.trim());

    if (grams == null || grams <= 0) { _showToast('common.pleaseEnterValidGrams'.tr()); return; }
    if (loss == null || loss < 0) { _showToast('common.pleaseEnterValidLoss'.tr()); return; }
    if (gramPrice == null || gramPrice <= 0) { _showToast('common.pleaseEnterValidGramPrice'.tr()); return; }

    final buyPrice = SilverDoubleSellPriceCalculator.buyPrice(
      grams: grams,
      loss: loss,
      gramPrice: gramPrice,
    );

    widget.onAddItem(
      DoubleSellCartItemModel(
        key: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'buy',
        title: '${carat.carat} • ${box.name}',
        subtitle: 'silver_double_sell.buyItem'.tr(),
        grams: grams,
        price: buyPrice,
        payload: {
          'carat_id': carat.id,
          'box_id': box.id,
          'grams': grams,
          'loss': loss,
          'gram_price': gramPrice,
          'buy_price': buyPrice,
        },
      ),
    );

    _gramsController.clear();
    _lossController.text = '0';
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
