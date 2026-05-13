import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalSnackBar extends StatefulWidget {
  const GlobalSnackBar.success({
    super.key,
    this.gradient = const [],
    required this.message,
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.icon = const Icon(
      Icons.sentiment_very_satisfied,
      color: Color(0x15000000),
      size: 70,
    ),
    this.textStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11.7,
      color: Colors.white,
    ),
    this.maxLines = 2,
    this.iconRotationAngle = 0,
    this.iconPositionTop = -20,
    this.iconPositionLeft = -8,
    this.backgroundColor = const Color(0xff00E676),
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    this.textAlign = TextAlign.center,
  });

  const GlobalSnackBar.info({
    super.key,
    required this.message,
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.icon = const Icon(
      Icons.sentiment_neutral,
      color: Color(0x15000000),
      size: 70,
    ),
    this.textStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11.7,
      color: Colors.white,
    ),
    this.gradient = const [],
    this.maxLines = 2,
    this.iconRotationAngle = 0,
    this.iconPositionTop = -20,
    this.iconPositionLeft = -8,
    this.backgroundColor = const Color(0xff2196F3),
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    this.textAlign = TextAlign.center,
  });

  const GlobalSnackBar.error({
    super.key,
    required this.message,
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 40),
    this.icon = const Icon(
      Icons.error_outline,
      color: Color(0x15000000),
      size: 70,
    ),
    this.gradient = const [],
    this.textStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Colors.white,
    ),
    this.maxLines = 2,
    this.iconRotationAngle = 0,
    this.iconPositionTop = -20,
    this.iconPositionLeft = -8,
    this.backgroundColor = const Color(0xffff5252),
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    this.textAlign = TextAlign.center,
  });

  final String message;
  final Widget icon;
  final Color backgroundColor;
  final TextStyle textStyle;
  final int maxLines;
  final int iconRotationAngle;
  final List<BoxShadow> boxShadow;
  final BorderRadius borderRadius;
  final double iconPositionTop;
  final double iconPositionLeft;
  final EdgeInsetsGeometry messagePadding;
  final double textScaleFactor;
  final TextAlign textAlign;
  final List<Color>? gradient;

  @override
  GlobalSnackBarState createState() => GlobalSnackBarState();
}

class GlobalSnackBarState extends State<GlobalSnackBar> {
  String _preparedMessage() {
    final compact = widget.message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 260) {
      return compact;
    }
    return '${compact.substring(0, 260)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = _preparedMessage();

    return Container(
      clipBehavior: Clip.hardEdge,
      height: 70.h,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
        gradient: LinearGradient(colors: widget.gradient ?? []),
      ),
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            height: 70,
            child: Transform.rotate(
              angle: widget.iconRotationAngle * pi / 180,
              child: widget.icon,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: widget.messagePadding,
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.merge(widget.textStyle),
                  textAlign: widget.textAlign,
                  maxLines: widget.maxLines,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.linear(widget.textScaleFactor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const kDefaultBoxShadow = [
  BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 8),
    spreadRadius: 1,
    blurRadius: 30,
  ),
];

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(15));
