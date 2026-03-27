import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';

/// Acciones de bicicleta que conectan la UI con el BikeProvider real.
class BikeActionsStubs {
  /// Reporta el robo de una bicicleta usando el BikeProvider.
  static Future<void> reportTheft(
    BuildContext context, {
    required String bikeId,
  }) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);

    final reporterId = FirebaseAuth.instance.currentUser?.uid;
    if (reporterId == null || reporterId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('error_user_not_logged_in'))));
      return;
    }

    final success = await bikeProvider.reportTheft(
      bikeId: bikeId,
      reporterId: reporterId,
      theftDate: DateTime.now(),
      location: '',
      description: l.t('theft_reported_by_owner'),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l.t('theft_report_sent_success')
                : l.t('theft_report_sent_error'),
          ),
        ),
      );
    }
  }

  /// Marca una bicicleta como recuperada usando el BikeProvider.
  static Future<void> markRecovered(
    BuildContext context, {
    required String bikeId,
  }) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    try {
      final repo = BikeRepositoryImpl();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await repo.markAsRecovered(bikeId, uid);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('bike_marked_recovered_success'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('bike_marked_recovered_error'))),
        );
      }
    }
  }

  /// Solicita la transferencia de propiedad usando el BikeProvider.
  static Future<void> transferOwnership(
    BuildContext context, {
    required String bikeId,
    required String newOwnerId,
  }) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);

    final fromUserId = FirebaseAuth.instance.currentUser?.uid;
    if (fromUserId == null || fromUserId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('error_user_not_logged_in'))));
      return;
    }

    final success = await bikeProvider.requestTransfer(
      bikeId: bikeId,
      fromUserId: fromUserId,
      toUserId: newOwnerId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l.t('transfer_request_sent_success')
                : l.t('transfer_request_sent_error'),
          ),
        ),
      );
    }
  }
}
