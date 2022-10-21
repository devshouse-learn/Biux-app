import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class TexFieldWidget extends StatefulWidget {
  TexFieldWidget({
    Key? key,
    required this.nameController,
    required this.text,
    required this.icon,
    required this.focusNode,
    this.validator,
    this.color,
    this.onChanged,
    this.keyboardType,
    this.maxLength,
    this.iconButton,
    this.obscureText,
    this.saved,
    this.enabled,
  }) : super(key: key);
  final String text;
  final Widget icon;
  final IconButton? iconButton;
  bool? obscureText = true;
  final TextEditingController nameController;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final Color? color;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? saved;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool? enabled;

  @override
  _TexFieldWidgetState createState() => _TexFieldWidgetState();
}

class _TexFieldWidgetState extends State<TexFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: AppColors.strongCyan,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 5,
          bottom: 5,
        ),
        child: SizedBox(
          child: TextFormField(
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            focusNode: widget.focusNode,
            style: Styles.textLightBlack,
            controller: widget.nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorStyle: TextStyle(fontSize: 1, height: 0),
              fillColor: AppColors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.gray,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.gray,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              contentPadding: EdgeInsets.fromLTRB(
                10.0,
                15.0,
                20.0,
                15.0,
              ),
              hintText: widget.text,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.red,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.red,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: widget.icon,
              suffixIcon: widget.iconButton,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.gray,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(45),
                ),
              ),
              hintStyle: Styles.sizedBoxHintStyle,
            ),
            obscureText: widget.obscureText!,
            onChanged: widget.onChanged,
            validator: widget.validator,
            onSaved: widget.saved,
          ),
        ),
      ),
    );
  }
}
