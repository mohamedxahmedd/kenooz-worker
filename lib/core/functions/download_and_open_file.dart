import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kenooz_worker_app/core/utilies/easy_loading.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';



Future<void> downloadAndOpenPdf(
  String url,
  BuildContext context,
) async {
  try {
    showLoading();
    // Get the document directory
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/${getFileName(url)}";

    // Download the PDF
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      hideLoading();
      print('PDF downloaded to: $filePath');
      // Open the file
      await OpenFile.open(filePath);
    } else {
      hideLoading();
      failureSnackBar(msg: "Failed to download PDF", context: context);
      print("Failed to download PDF: ${response.statusCode}");
    }
  } catch (e) {
    hideLoading();
    failureSnackBar(msg: "Failed to download PDF", context: context);

    print("Error downloading or opening PDF: $e");
  }
}

String getFileName(String url) {
  return Uri.parse(url).pathSegments.last;
}
