import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class TextFormFieldBiuxWidget extends StatelessWidget {
  TextFormFieldBiuxWidget({
    Key? key,
    required this.controller,
    required this.text,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLength,
    this.iconButton,
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
  }) : super(key: key);
  final String text;
  final IconButton? iconButton;
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
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        // I remove this value by default since the size of the maxLines is not reflected
        // height: 48,
        child: TextFormField(
          autofocus: autofocus,
          style: TextStyle(
            color: AppColors.black,
          ),
          maxLines: maxLine,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLength: maxLength,
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
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
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray, width: 0.5),
              borderRadius: BorderRadius.circular(radiusCircular),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray, width: 0.5),
              borderRadius: BorderRadius.circular(radiusCircular),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray, width: 0.5),
              borderRadius: BorderRadius.all(
                Radius.circular(radiusCircular),
              ),
            ),
            hintStyle: Styles.sizedBoxHintStyle,
          ),
          onChanged: onChanged,
          validator: validator,
          onSaved: saved,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ),
    );
  }
}
