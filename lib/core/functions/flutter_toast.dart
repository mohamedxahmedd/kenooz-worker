import 'package:flutter/material.dart';
import 'package:kenooz_worker_app/core/services/toast_service.dart';

void customToast({
  required String msg,
  required Color color,
}) =>
    ToastService.show(msg, background: color);
