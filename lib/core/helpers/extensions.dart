import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';


extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
      String routeName, bool Function(dynamic route) param1,
      {Object? arguments, required RoutePredicate predicate}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop({bool? isTrue}) => Navigator.of(this).pop(
        isTrue ?? false,
      );
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
  String formatAsDayMonthYear() {
    if (this == null || this!.isEmpty) return "";

    final date = DateTime.parse(this!.replaceAll('.000000Z', 'Z'));
    final locale = CacheHelper.isEnglish() ? 'en' : 'ar';
    return DateFormat('d MMM, y', locale).format(date); // e.g. 3 Jun, 2025
  }

  String formatDateHeader() {
    if (this == null || this!.isEmpty) return "";

    final date = DateTime.parse(this!.replaceAll('.000000Z', 'Z'));
    if (!CacheHelper.isEnglish()) {
      return DateFormat('EEE, d MMM', 'ar').format(date);
    } else {
      return DateFormat('EEE, d MMM', 'en').format(date);
    }
  }

  bool isExpired() {
    try {
      final DateTime end = DateTime.parse(this!);
      final DateTime now = DateTime.now();
      return end.isBefore(now);
    } catch (e) {
      return false;
    }
  }
}

extension NumberRangeExtension on num {
  bool isBetween0And50() => this >= 0 && this < 50;

  bool isBetween51And75() => this >= 50 && this < 75;

  bool isBetween75And100() => this >= 75 && this <= 100;
}
