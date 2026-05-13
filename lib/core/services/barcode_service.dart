import 'package:flutter/material.dart';

/// Desktop barcode entry. We don't have a live camera scanner on desktop —
/// workers use a hardware (USB / Bluetooth) scanner that types into the
/// product-ID field directly — so the only API here is a manual-entry dialog
/// kept around for screens that want a "type a code" fallback.
class BarcodeService {
  BarcodeService._();
  static final BarcodeService instance = BarcodeService._();

  /// Always `false`: live camera scanning is not supported on desktop.
  bool get supportsLiveScan => false;

  /// Shows a dialog that lets the user type or paste a code. Returns the
  /// trimmed value, or `null` if the user cancelled / submitted blank.
  Future<String?> promptForCode(
    BuildContext context, {
    required String title,
    required String hint,
    required String addLabel,
    required String cancelLabel,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint),
            onSubmitted: (text) =>
                Navigator.of(dialogCtx).pop(text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(cancelLabel),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogCtx).pop(controller.text.trim()),
              child: Text(addLabel),
            ),
          ],
        );
      },
    );
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
