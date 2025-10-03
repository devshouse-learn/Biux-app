import 'package:biux/core/config/colors.dart';
import 'package:biux/core/config/styles.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static SnackBar customSnackBar({
    required String content,
    Color backgroundColor = AppColors.strongCyan,
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
