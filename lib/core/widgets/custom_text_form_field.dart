import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';


class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool? obscureText;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final bool? readOnly;
  final bool? showCursor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final bool isChat;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final FormFieldSetter<String>? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? enabled;
  final Iterable<String>? autofillHints;
  final EdgeInsets? contentPadding;
  final EdgeInsets? padding;
  final bool? expands;
  final int? maxLines;
  final int? minLines;
  final TextAlign? textAlign;
  final ValueChanged<String>? onFieldSubmitted;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? height;
  final InputBorder? enabledBorder;
  final FocusNode? focusNode;
  final FocusNode? foucseNode;
  final InputBorder? focusedBorder;
  final Color? fillColor;
  final double? width;
  const CustomTextFormField({
    super.key,
    this.controller,
    this.isChat = false,
    this.padding,
    this.textStyle,
    this.hintStyle,
    this.hintText,
    this.labelText,
    this.backgroundColor,
    this.helperText,
    this.borderColor,
    this.borderWidth,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.borderRadius,
    this.onSaved,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled,
    this.autofillHints,
    this.contentPadding,
    this.expands,
    this.maxLines,
    this.minLines,
    this.textAlign,
    this.onFieldSubmitted,
    this.buildCounter,
    this.scrollPhysics,
    this.onTap,
    this.height,
    this.enabledBorder,
    this.focusedBorder,
    this.focusNode,
    this.foucseNode,
    this.fillColor,
    this.width,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    final effectiveFocusNode = widget.focusNode ?? widget.foucseNode;

    return Container(
      height: widget.height ?? 75.h,
      padding: widget.padding,
      width: widget.width,
      alignment: Alignment.center,
      child: Center(
        child: TextFormField(
          focusNode: effectiveFocusNode,
          style: widget.textStyle ?? AppFonts.body(fontSize: 14.sp),
          autofillHints: widget.autofillHints,
          onTapOutside: widget.isChat
              ? null
              : (event) => FocusScope.of(context).unfocus(),
          controller: widget.controller,
          obscureText: widget.obscureText!,
          autofocus: widget.autofocus!,
          autocorrect: widget.autocorrect!,
          enableSuggestions: widget.enableSuggestions!,
          readOnly: widget.readOnly!,
          showCursor: widget.showCursor,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          validator: widget.validator,
          onSaved: widget.onSaved,
          inputFormatters: widget.inputFormatters,
          buildCounter: widget.buildCounter,
          textAlign: widget.textAlign ?? TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            fillColor: widget.fillColor,
            filled: true,
            floatingLabelStyle: AppFonts.body(
              fontSize: 10.sp,
              color: AppColors.greenColor,
            ),
            focusedBorder:
                widget.focusedBorder ??
                OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.borderColor ?? AppColors.greenColor,
                    width: (widget.borderWidth) ?? 1.sp,
                  ),
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(30.0.sp),
                ),
            enabledBorder:
                widget.enabledBorder ??
                OutlineInputBorder(
                  gapPadding: 01,
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.grey.shade400,
                    width: widget.borderWidth ?? 1.sp,
                  ),
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(30.sp),
                ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.sp),
              borderRadius:
                  widget.borderRadius ?? BorderRadius.circular(30.0.sp),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.sp),
              borderRadius: BorderRadius.circular(30.0.sp),
            ),
            border: const UnderlineInputBorder(borderSide: BorderSide.none),
            labelText: widget.labelText,
            hintStyle: widget.hintStyle ?? AppFonts.body(fontSize: 14.sp),
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            labelStyle: AppFonts.body(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
            suffixIcon: widget.suffixIcon,
            enabled: widget.enabled ?? true,
            contentPadding:
                widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          ),
          expands: widget.expands ?? false,
          maxLines: widget.maxLines ?? 1,
          minLines: widget.minLines,
          onFieldSubmitted: widget.onFieldSubmitted,
          scrollPhysics: widget.scrollPhysics,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
