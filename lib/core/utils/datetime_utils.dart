import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String dateTimeformatterNative(
    TimeOfDay timeOfDay,
  ) {
    final date = DateTime(
      year,
      month,
      day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    return formattedDate;
  }
}
