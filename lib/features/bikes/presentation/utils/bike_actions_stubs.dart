import 'package:flutter/material.dart';

class BikeActionsStubs {
  static void reportTheft(BuildContext context, {required String bikeId}) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte de robo enviado (stub).')));
  }

  static void markRecovered(BuildContext context, {required String bikeId}) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marcado como recuperada (stub).')));
  }

  static void transferOwnership(BuildContext context, {required String bikeId, required String newOwnerId}) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transferencia iniciada (stub).')));
  }
}
