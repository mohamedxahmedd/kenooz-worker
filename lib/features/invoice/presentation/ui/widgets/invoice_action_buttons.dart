import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/cubit/invoice_state.dart';
import 'package:kenooz_worker_app/features/invoice/presentation/ui/widgets/invoice_type.dart';
import 'invoice_listener.dart';

class InvoiceActionButtons extends StatelessWidget {
  final InvoiceType type;
  final int id;
  final Color accentColor;

  const InvoiceActionButtons({
    super.key,
    required this.type,
    required this.id,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InvoiceCubit>(
      create: (_) => InvoiceCubit(getIt()),
      child: InvoiceListener(
        child: BlocBuilder<InvoiceCubit, InvoiceState>(
          builder: (context, state) {
            final cubit = context.read<InvoiceCubit>();
            final loadingAction = state.maybeWhen(
              loading: (action) => action,
              orElse: () => null,
            );

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: Icons.picture_as_pdf_rounded,
                  color: accentColor,
                  tooltip: 'invoice.openInvoice'.tr(),
                  isLoading: loadingAction == InvoiceAction.open,
                  isDisabled: loadingAction != null,
                  onPressed: () =>
                      cubit.downloadAndOpen(type: type, id: id),
                ),
                _ActionIconButton(
                  icon: Icons.share_rounded,
                  color: const Color(0xff25D366),
                  tooltip: 'invoice.shareInvoice'.tr(),
                  isLoading: loadingAction == InvoiceAction.share,
                  isDisabled: loadingAction != null,
                  onPressed: () =>
                      cubit.downloadAndShare(type: type, id: id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isDisabled ? null : onPressed,
      tooltip: tooltip,
      icon: isLoading
          ? SizedBox(
              width: 18.sp,
              height: 18.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          : Icon(icon, size: 22.sp, color: color),
    );
  }
}

