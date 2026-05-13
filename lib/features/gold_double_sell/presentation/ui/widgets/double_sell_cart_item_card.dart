import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class DoubleSellCartItemModel {
  final String key;
  final String type;
  final String title;
  final String subtitle;
  final double grams;
  final double price;
  final Map<String, dynamic> payload;

  const DoubleSellCartItemModel({
    required this.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.grams,
    required this.price,
    required this.payload,
  });

  DoubleSellCartItemModel copyWith({
    String? key,
    String? type,
    String? title,
    String? subtitle,
    double? grams,
    double? price,
    Map<String, dynamic>? payload,
  }) {
    return DoubleSellCartItemModel(
      key: key ?? this.key,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      grams: grams ?? this.grams,
      price: price ?? this.price,
      payload: payload ?? this.payload,
    );
  }
}

class DoubleSellCartItemCard extends StatefulWidget {
  final DoubleSellCartItemModel item;
  final Color accentColor;
  final bool priceEditable;
  final ValueChanged<double>? onPriceChanged;
  final VoidCallback? onDelete;

  const DoubleSellCartItemCard({
    super.key,
    required this.item,
    required this.accentColor,
    this.priceEditable = false,
    this.onPriceChanged,
    this.onDelete,
  });

  @override
  State<DoubleSellCartItemCard> createState() => _DoubleSellCartItemCardState();
}

class _DoubleSellCartItemCardState extends State<DoubleSellCartItemCard> {
  late final TextEditingController _priceController;
  late final FocusNode _priceFocusNode;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.price.toStringAsFixed(2),
    );
    _priceFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant DoubleSellCartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.price != oldWidget.item.price &&
        !_priceFocusNode.hasFocus) {
      _priceController.text = widget.item.price.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  void _commitPriceChange() {
    final value = double.tryParse(_priceController.text.trim());
    if (value == null || value <= 0) {
      _priceController.text = widget.item.price.toStringAsFixed(2);
      return;
    }
    widget.onPriceChanged?.call(value);
  }

  String _subtitleWithoutVendor() {
    final subtitle = widget.item.subtitle;
    final vendorSplitIndex = subtitle.toLowerCase().indexOf('• vendor:');
    if (vendorSplitIndex >= 0) {
      return subtitle.substring(0, vendorSplitIndex).trim();
    }

    if (subtitle.toLowerCase().startsWith('outside •')) {
      return 'common.outside'.tr();
    }

    return subtitle;
  }

  double? _itemProfit() {
    final raw = widget.item.payload['profit'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = _subtitleWithoutVendor();
    final itemProfit = _itemProfit();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkThemeContainerColorElevated
            : AppColors.backGroundColorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : widget.accentColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sell_rounded,
              color: widget.accentColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${widget.item.grams.toStringAsFixed(2)} g',
                  style: AppFonts.body(
                    fontSize: 10.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.textGreyColor
                          : AppColors.darkGreyTextColor,
                    ),
                  ),
                ],
                if (itemProfit != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    '${'common.profit'.tr()}: ${itemProfit.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.priceEditable)
                SizedBox(
                  width: 108.w,
                  height: 38.h,
                  child: TextFormField(
                    controller: _priceController,
                    focusNode: _priceFocusNode,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    onFieldSubmitted: (_) => _commitPriceChange(),
                    onTapOutside: (_) => _commitPriceChange(),
                    style: AppFonts.body(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successColor,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.successColor.withOpacity(0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: AppColors.successColor,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  widget.item.price.toStringAsFixed(2),
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                  ),
                ),
              SizedBox(height: 2.h),
              if (widget.onDelete != null)
                SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                      size: 20.sp,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
