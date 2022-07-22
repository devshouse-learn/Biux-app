import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: AppColors.black,
      content: Text(
        content,
        style: Styles.snackBarContent,
      ),
    );
  }
}
