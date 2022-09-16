import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static SnackBar customSnackBar({
    required String content,
    Color backgroundColor = AppColors.black,
  }) {
    return SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        content,
        style: Styles.snackBarContent,
      ),
    );
  }
}
