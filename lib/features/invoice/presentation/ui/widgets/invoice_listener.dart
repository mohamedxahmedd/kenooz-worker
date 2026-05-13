import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/cubit/invoice_state.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceListener extends StatelessWidget {
  final Widget child;

  const InvoiceListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceCubit, InvoiceState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: (_) => EasyLoading.show(status: 'invoice.downloading'.tr()),
          success: (file, action) async {
            EasyLoading.dismiss();
            if (action == InvoiceAction.open) {
              final result = await OpenFile.open(file.path);
              if (result.type != ResultType.done && context.mounted) {
                failureSnackBar(
                  msg: result.message,
                  context: context,
                );
              }
            } else {
              await Share.shareXFiles([XFile(file.path)]);
              if (context.mounted) {
                successSnackBar(
                  msg: 'invoice.shareReady'.tr(),
                  context: context,
                );
              }
            }
          },
          error: (messages) {
            EasyLoading.dismiss();
            failureSnackBar(
              msg: messages.isEmpty
                  ? 'invoice.downloadFailed'.tr()
                  : messages.join('\n'),
              context: context,
            );
          },
        );
      },
      child: child,
    );
  }
}
