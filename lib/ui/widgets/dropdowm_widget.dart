library dropdown_formfield;

import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:flutter/material.dart';

class DropDownFormField extends FormField<dynamic> {
  final String titleText;
  final String hintText;
  final bool required;
  final String errorText;
  final dynamic value;
  final List? dataSource;
  final String? textField;
  final String? valueField;
  final Function? onChanged;
  final bool? filled;
  final String? iconField;
  final String? imageField;

  DropDownFormField({
    FormFieldSetter<dynamic>? onSaved,
    FormFieldValidator<dynamic>? validator,
    bool autovalidate = false,
    this.titleText = AppStrings.title,
    this.hintText = AppStrings.selectOption,
    this.required = false,
    this.errorText = AppStrings.selectOption2,
    this.value,
    this.dataSource,
    this.textField,
    this.valueField,
    this.onChanged,
    this.iconField,
    this.imageField,
    this.filled = true,
    InputDecoration? decoration,
    Icon? child,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          initialValue: value == '' ? null : value,
          builder: (FormFieldState<dynamic> state) {
            return Container(
              child: SizedBox(
                height: 50,
                width: 330,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InputDecorator(
                      decoration: InputDecoration.collapsed(
                        hintText: "",
                        filled: filled,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          isExpanded: true,
                          hint: Text(
                            hintText,
                          ),
                          value: value == '' ? null : value,
                          onChanged: (dynamic newValue) {
                            state.didChange(newValue);
                            onChanged!(newValue);
                          },
                          items: dataSource!.map(
                            (item) {
                              return DropdownMenuItem<dynamic>(
                                value: item[valueField],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: item[iconField] == null
                                      ? item[imageField] == null
                                          ? <Widget>[
                                              Text(item[textField]),
                                            ]
                                          : <Widget>[
                                              Image(
                                                image: item[imageField],
                                              ),
                                              SizedBox(width: 5),
                                              Text(item[textField]),
                                            ]
                                      : <Widget>[
                                          Icon(item[iconField]),
                                          SizedBox(width: 5),
                                          Text(item[textField]),
                                        ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: state.hasError ? 2.0 : 0.0,
                    ),
                    Text(
                      state.hasError.toString(),
                      style: state.hasError
                          ? Styles.hasErrorShow
                          : Styles.hasErrorHide,
                    ),
                  ],
                ),
              ),
            );
          },
        );
}
