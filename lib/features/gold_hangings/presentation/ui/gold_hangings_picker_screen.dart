import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/services/barcode_service.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/cached_image_widget.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_top_snack_bar.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/available_gold_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/models/hang_request_model.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_available_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_available_state.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_hang_cubit.dart';
import 'package:kenooz_worker_app/features/gold_hangings/presentation/cubit/gold_hangings_hang_state.dart';

class GoldHangingsPickerScreen extends StatefulWidget {
  const GoldHangingsPickerScreen({super.key});

  @override
  State<GoldHangingsPickerScreen> createState() =>
      _GoldHangingsPickerScreenState();
}

class _GoldHangingsPickerScreenState extends State<GoldHangingsPickerScreen> {
  final TextEditingController _noteCtrl = TextEditingController();
  final List<AvailableGoldModel> _selected = [];

  String? _lastScannedCode;
  DateTime? _lastScannedAt;
  static const Duration _scanDebounce = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    context.read<GoldHangingsAvailableCubit>().fetchAvailable();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _promptForManualCode() async {
    final code = await BarcodeService.instance.promptForCode(
      context,
      title: 'gold_hangings.enterCodeTitle'.tr(),
      hint: 'gold_hangings.enterCodeHint'.tr(),
      addLabel: 'common.add'.tr(),
      cancelLabel: 'common.cancel'.tr(),
      keyboardType: TextInputType.number,
    );
    if (code == null) return;
    _processScannedCode(code);
  }

  void _processScannedCode(String code) {
    final availableState = context.read<GoldHangingsAvailableCubit>().state;
    final available = availableState.maybeWhen(
      success: (items) => items,
      orElse: () => const <AvailableGoldModel>[],
    );
    if (available.isEmpty) return;

    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScannedAt != null &&
        now.difference(_lastScannedAt!) < _scanDebounce) {
      return;
    }
    _lastScannedCode = code;
    _lastScannedAt = now;

    final id = int.tryParse(code);
    if (id == null || id <= 0) {
      _flashError('gold_hangings.invalidBarcode'.tr());
      return;
    }

    if (_selected.any((e) => e.id == id)) {
      // Duplicate — silent ignore per spec.
      return;
    }

    AvailableGoldModel? match;
    for (final item in available) {
      if (item.id == id) {
        match = item;
        break;
      }
    }
    if (match == null) {
      _flashError('gold_hangings.notAvailable'.tr());
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _selected.add(match!));
  }

  void _flashError(String message) {
    HapticFeedback.lightImpact();
    failureSnackBar(msg: message, context: context);
  }

  void _removeOne(int id) {
    setState(() => _selected.removeWhere((e) => e.id == id));
  }

  void _submit() {
    if (_selected.isEmpty) return;
    final note = _noteCtrl.text.trim();
    context.read<GoldHangingsHangCubit>().hangGolds(
      HangRequestModel(
        goldIds: _selected.map((e) => e.id).toList(),
        hangNote: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<GoldHangingsHangCubit, GoldHangingsHangState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => EasyLoading.show(),
          success: (data) {
            EasyLoading.dismiss();
            successSnackBar(msg: data.message, context: context);
            Navigator.pop(context, true);
          },
          error: (messages) {
            EasyLoading.dismiss();
            failureSnackBar(msg: messages.join('\n'), context: context);
            context.read<GoldHangingsHangCubit>().reset();
          },
        );
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkThemeBackgroundColor
            : AppColors.backGroundColorLight,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 10.h),
                child: _HeaderCard(
                  isDark: isDark,
                  selectedCount: _selected.length,
                ),
              ),
              _HardwareScannerCard(
                isDark: isDark,
                onScanned: _processScannedCode,
                onManualEntry: _promptForManualCode,
              ),
              Expanded(
                child: _SelectedBody(
                  isDark: isDark,
                  selected: _selected,
                  onRemove: _removeOne,
                ),
              ),
              _BottomBar(
                isDark: isDark,
                noteCtrl: _noteCtrl,
                selectedCount: _selected.length,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final bool isDark;
  final int selectedCount;
  const _HeaderCard({required this.isDark, required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primaryColor.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.darkBrown.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.darkBrown.withOpacity(0.1),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'gold_hangings.pickerTitle'.tr(),
                  style: AppFonts.heading(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'gold_hangings.scanToAdd'.tr(),
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.goldColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.goldColor.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmark_added_rounded,
                  size: 14.sp,
                  color: AppColors.goldColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  '$selectedCount',
                  style: AppFonts.body(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hardware scanner input (desktop). A USB/Bluetooth barcode scanner acts as a
// keyboard, so we keep a focused TextField "armed" — when the scanner sends
// the code followed by Enter, `onSubmitted` fires and we hand the value to
// the same processing pipeline the camera path uses. The field auto-clears
// and re-focuses for the next scan.
// ─────────────────────────────────────────────────────────────────────────────

class _HardwareScannerCard extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> onScanned;
  final VoidCallback onManualEntry;

  const _HardwareScannerCard({
    required this.isDark,
    required this.onScanned,
    required this.onManualEntry,
  });

  @override
  State<_HardwareScannerCard> createState() => _HardwareScannerCardState();
}

class _HardwareScannerCardState extends State<_HardwareScannerCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _lastScanned;
  DateTime? _lastScannedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    final code = value.trim();
    _controller.clear();
    // Always re-arm for the next scan.
    _focusNode.requestFocus();
    if (code.isEmpty) return;
    setState(() {
      _lastScanned = code;
      _lastScannedAt = DateTime.now();
    });
    widget.onScanned(code);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark
        ? AppColors.darkThemeContainerColor
        : Colors.white;
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : AppColors.primaryColor.withOpacity(0.14);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.goldColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.goldColor.withOpacity(0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.goldColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'gold_hangings.scannerReady'.tr(),
                        style: AppFonts.heading(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? AppColors.lightTextColorForDarkMood
                              : AppColors.darkBrown,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'gold_hangings.scannerReadyHint'.tr(),
                        style: AppFonts.body(
                          fontSize: 11.sp,
                          color: widget.isDark
                              ? AppColors.textGreyColor
                              : AppColors.darkGreyTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _ListeningBadge(focusNode: _focusNode),
              ],
            ),
            SizedBox(height: 12.h),
            // The always-armed scanner input. When the hardware scanner fires
            // it types the code + Enter, which triggers onSubmitted below.
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: _onSubmitted,
              style: AppFonts.body(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? AppColors.lightTextColorForDarkMood
                    : AppColors.darkBrown,
              ),
              decoration: InputDecoration(
                hintText: 'gold_hangings.scannerInputHint'.tr(),
                hintStyle: AppFonts.body(
                  fontSize: 12.sp,
                  color: widget.isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                ),
                prefixIcon: const Icon(Icons.center_focus_strong_rounded),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.primaryColor.withOpacity(0.04),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: AppColors.goldColor.withOpacity(0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: AppColors.goldColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                      BorderSide(color: AppColors.goldColor, width: 1.6),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (_lastScanned != null && _lastScannedAt != null)
                  Expanded(
                    child: _LastScanIndicator(
                      isDark: widget.isDark,
                      code: _lastScanned!,
                      at: _lastScannedAt!,
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'gold_hangings.scannerInstructions'.tr(),
                      style: AppFonts.body(
                        fontSize: 11.sp,
                        color: widget.isDark
                            ? AppColors.textGreyColor
                            : AppColors.darkGreyTextColor,
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: widget.onManualEntry,
                  icon: Icon(Icons.keyboard_alt_outlined, size: 16.sp),
                  label: Text('gold_hangings.typeManually'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningBadge extends StatelessWidget {
  const _ListeningBadge({required this.focusNode});
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final listening = focusNode.hasFocus;
        final color = listening
            ? AppColors.goldColor
            : AppColors.textGreyColor;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                listening
                    ? 'gold_hangings.listening'.tr()
                    : 'gold_hangings.notListening'.tr(),
                style: AppFonts.body(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LastScanIndicator extends StatelessWidget {
  const _LastScanIndicator({
    required this.isDark,
    required this.code,
    required this.at,
  });
  final bool isDark;
  final String code;
  final DateTime at;

  @override
  Widget build(BuildContext context) {
    final relative = _formatRelative(DateTime.now().difference(at));
    return Text(
      'gold_hangings.lastScan'.tr(args: [code, relative]),
      style: AppFonts.body(
        fontSize: 11.sp,
        color: isDark ? AppColors.textGreyColor : AppColors.darkGreyTextColor,
      ),
    );
  }

  String _formatRelative(Duration d) {
    if (d.inSeconds < 5) return 'just now';
    if (d.inSeconds < 60) return '${d.inSeconds}s ago';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected products list (or empty / loading / error states for available)
// ─────────────────────────────────────────────────────────────────────────────

class _SelectedBody extends StatelessWidget {
  final bool isDark;
  final List<AvailableGoldModel> selected;
  final ValueChanged<int> onRemove;

  const _SelectedBody({
    required this.isDark,
    required this.selected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoldHangingsAvailableCubit, GoldHangingsAvailableState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => _LoadingPlaceholder(isDark: isDark),
          error: (message) => _ErrorView(
            isDark: isDark,
            message: message,
            onRetry: () =>
                context.read<GoldHangingsAvailableCubit>().fetchAvailable(),
          ),
          orElse: () => selected.isEmpty
              ? _EmptyState(isDark: isDark)
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                  itemCount: selected.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final item = selected[index];
                    return _SelectedCard(
                      item: item,
                      isDark: isDark,
                      onRemove: () => onRemove(item.id),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final bool isDark;
  const _LoadingPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.goldColor),
          SizedBox(height: 12.h),
          Text(
            'gold_hangings.loadingInventory'.tr(),
            style: AppFonts.body(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              size: 50.sp,
              color: isDark
                  ? AppColors.textGreyColor
                  : AppColors.darkGreyTextColor,
            ),
            SizedBox(height: 10.h),
            Text(
              'gold_hangings.scanToStart'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.errorColor.withOpacity(0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.errorColor,
                size: 30.sp,
              ),
              SizedBox(height: 10.h),
              Text(
                'common.unableToLoadData'.tr(),
                style: AppFonts.heading(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkBrown,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textGreyColor
                      : AppColors.darkGreyTextColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('common.retry'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCard extends StatelessWidget {
  final AvailableGoldModel item;
  final bool isDark;
  final VoidCallback onRemove;
  const _SelectedCard({
    required this.item,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.goldColor.withOpacity(isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.goldColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: (item.image != null && item.image!.isNotEmpty)
                ? CachedNetworkImageWidget(
                    imageUrl: item.image!,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 20.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${item.id}  ${item.name}',
                  style: AppFonts.heading(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.lightTextColorForDarkMood
                        : AppColors.darkBrown,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.kind.name} • ${'common.carat'.tr()} ${item.carat.carat} • ${item.grams.toStringAsFixed(2)}g',
                  style: AppFonts.body(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.textGreyColor
                        : AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: AppColors.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom bar: note + submit button
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isDark;
  final TextEditingController noteCtrl;
  final int selectedCount;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isDark,
    required this.noteCtrl,
    required this.selectedCount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeContainerColor : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.primaryColor.withOpacity(0.12),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'gold_hangings.noteLabel'.tr(),
            style: AppFonts.body(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: noteCtrl,
            maxLines: 2,
            maxLength: 1000,
            textInputAction: TextInputAction.done,
            style: AppFonts.body(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.lightTextColorForDarkMood
                  : AppColors.darkBrown,
            ),
            decoration: InputDecoration(
              hintText: 'gold_hangings.noteHint'.tr(),
              hintStyle: AppFonts.body(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textGreyColor
                    : AppColors.darkGreyTextColor,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.primaryColor.withOpacity(0.04),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.primaryColor.withOpacity(0.16),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.primaryColor.withOpacity(0.16),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                    BorderSide(color: AppColors.goldColor, width: 1.4),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedCount == 0 ? null : onSubmit,
              icon: Icon(Icons.bookmark_added_rounded, size: 18.sp),
              label: Text(
                selectedCount == 0
                    ? 'gold_hangings.hangSelected'.tr()
                    : 'gold_hangings.hangCount'.tr(
                        args: [selectedCount.toString()],
                      ),
                style: AppFonts.body(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldColor,
                disabledBackgroundColor: isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.primaryColor.withOpacity(0.18),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
