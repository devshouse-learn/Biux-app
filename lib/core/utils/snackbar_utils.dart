import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/styles.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static SnackBar customSnackBar({
    required String content,
    Color backgroundColor = ColorTokens.secondary50,
  }) {
    return SnackBar(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      )),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: Styles.snackBarContent,
      ),
    );
  }
}
