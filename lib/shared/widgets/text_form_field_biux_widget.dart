import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/styles.dart';
import 'package:flutter/material.dart';

class TextFormFieldBiuxWidget extends StatelessWidget {
  TextFormFieldBiuxWidget({
    Key? key,
    required this.controller,
    required this.text,
    this.addButton,
    this.image,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLength,
    this.prefixIcon,
    this.saved,
    this.enabled = true,
    this.maxLine,
    this.radiusCircular = 45,
    this.padding = const EdgeInsets.only(
      left: 15,
      right: 15,
      top: 5,
      bottom: 5,
    ),
    this.autofocus = false,
    this.onFieldSubmitted,
    this.fontSize = 18,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);
  final String text;
  final Widget? prefixIcon;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? saved;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool enabled;
  final int? maxLine;
  final double radiusCircular;
  final EdgeInsetsGeometry padding;
  final bool autofocus;
  final Widget? image;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final double fontSize;
  final bool readOnly;
  final Widget? addButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        child: TextFormField(
          autofocus: autofocus,
          style: enabled ? Styles.textLightBlack : Styles.sizedBoxHintStyle,
          maxLines: maxLine,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLength: maxLength,
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 1, height: 0),
            fillColor: AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(radiusCircular),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(radiusCircular),
            ),
            filled: true,
            contentPadding: EdgeInsets.fromLTRB(
              10.0,
              15.0,
              20.0,
              15.0,
            ),
            hintText: text,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIcon != null
                ? BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  )
                : BoxConstraints(),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.red,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(radiusCircular),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.red,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(radiusCircular),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
                width: 0.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(radiusCircular),
              ),
            ),
            suffixIcon: onFieldSubmitted != null
                ? addButton
                : SizedBox(),
            hintStyle: Styles.sizedBoxHintStyle.copyWith(
              fontSize: fontSize,
            ),
          ),
          onChanged: onChanged,
          validator: validator,
          onSaved: saved,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
        ),
      ),
    );
  }
}
