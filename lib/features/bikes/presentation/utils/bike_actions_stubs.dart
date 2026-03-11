import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class BikeActionsStubs {
  static void reportTheft(BuildContext context, {required String bikeId}) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.t('stub_theft_report_sent'))));
  }

  static void markRecovered(BuildContext context, {required String bikeId}) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.t('stub_marked_recovered'))));
  }

  static void transferOwnership(
    BuildContext context, {
    required String bikeId,
    required String newOwnerId,
  }) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.t('stub_transfer_initiated'))));
  }
}
