import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/features/social/data/models/attendee_model.dart';
import "package:flutter/foundation.dart";

/// Adaptador que sincroniza asistentes entre Realtime DB y Firestore
///
/// Mantiene compatibilidad con el sistema existente:
/// - Realtime DB: /rides/attendees/{rideId}/{userId}
/// - Firestore: /rides/{rideId}/participants y /maybeParticipants
class AttendeesFirestoreAdapter {
  final FirebaseDatabase _realtimeDb;
  final FirebaseFirestore _firestore;
  final Map<String, StreamSubscription> _subscriptions = {};

  AttendeesFirestoreAdapter({
    FirebaseDatabase? realtimeDb,
    FirebaseFirestore? firestore,
  }) : _realtimeDb = realtimeDb ?? FirebaseDatabase.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sincroniza cambios de Realtime DB a†’ Firestore
  /// Escucha todos los cambios en asistentes y actualiza Firestore
  void startSyncForRide(String rideId) {
    // No crear duplicados
    if (_subscriptions.containsKey(rideId)) return;

    final ref = _realtimeDb.ref('rides/attendees/$rideId');

    _subscriptions[rideId] = ref.onValue.listen((event) {
      if (event.snapshot.value == null) {
        _updateFirestoreAttendees(rideId, [], []);
        return;
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final attendees = <AttendeeModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          attendees.add(AttendeeModel.fromJson(key, value));
        }
      });

      // Separar por estado
      final confirmed = attendees
          .where((a) => a.status == 'confirmed')
          .map((a) => a.userId)
          .toList();

      final maybe = attendees
          .where((a) => a.status == 'maybe')
          .map((a) => a.userId)
          .toList();

      _updateFirestoreAttendees(rideId, confirmed, maybe);
    });
  }

  /// Cancela todas las suscripciones activas
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Actualiza Firestore con las listas de asistentes
  Future<void> _updateFirestoreAttendees(
    String rideId,
    List<String> confirmed,
    List<String> maybe,
  ) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'participants': confirmed,
        'maybeParticipants': maybe,
      });
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error actualizando Firestore',
        error: e,
        tag: 'AttendeesFirestoreAdapter',
      );
    }
  }

  /// Migra un asistente de Firestore a†’ Realtime DB
  /// Ãštil para migración inicial de datos existentes
  Future<void> migrateFromFirestore(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final participants = List<String>.from(data['participants'] ?? []);
      final maybeParticipants = List<String>.from(
        data['maybeParticipants'] ?? [],
      );

      // Migrar confirmados
      for (final userId in participants) {
        final attendee = AttendeeModel(
          userId: userId,
          status: 'confirmed',
          joinedAt: DateTime.now().millisecondsSinceEpoch,
          userName: '', // Se actualizará desde el perfil
          userPhoto: null,
        );

        await _realtimeDb
            .ref('rides/attendees/$rideId/$userId')
            .set(attendee.toJson());
      }

      // Migrar "tal vez"
      for (final userId in maybeParticipants) {
        final attendee = AttendeeModel(
          userId: userId,
          status: 'maybe',
          joinedAt: DateTime.now().millisecondsSinceEpoch,
          userName: '',
          userPhoto: null,
        );

        await _realtimeDb
            .ref('rides/attendees/$rideId/$userId')
            .set(attendee.toJson());
      }

      AppLogger.debug(
        'Migrados $rideId: ${participants.length} confirmados, ${maybeParticipants.length} tal vez',
        tag: 'AttendeesFirestoreAdapter',
      );
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error migrando rodada $rideId',
        error: e,
        tag: 'AttendeesFirestoreAdapter',
      );
    }
  }

  /// Migra TODAS las rodadas existentes de Firestore a†’ Realtime DB
  Future<void> migrateAllRides() async {
    try {
      final ridesSnapshot = await _firestore.collection('rides').get();

      AppLogger.debug(
        'Iniciando migración de ${ridesSnapshot.docs.length} rodadas...',
        tag: 'AttendeesFirestoreAdapter',
      );

      for (final doc in ridesSnapshot.docs) {
        await migrateFromFirestore(doc.id);
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Evitar rate limiting
      }
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error en migración masiva',
        error: e,
        tag: 'AttendeesFirestoreAdapter',
      );
    }
  }

  /// Limpia asistentes cancelados de Firestore
  /// (Los usuarios con status='cancelled' ya no aparecen en las listas)
  Future<void> cleanCancelledAttendees(String rideId) async {
    final ref = _realtimeDb.ref('rides/attendees/$rideId');
    final snapshot = await ref.get();

    if (snapshot.value == null) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final toRemove = <String>[];

    data.forEach((key, value) {
      if (value is Map) {
        final status = value['status'] as String?;
        if (status == 'cancelled') {
          toRemove.add(key);
        }
      }
    });

    // Eliminar asistentes cancelados
    for (final userId in toRemove) {
      await ref.child(userId).remove();
    }

    AppLogger.debug(
      'Limpiados ${toRemove.length} asistentes cancelados de $rideId',
      tag: 'AttendeesFirestoreAdapter',
    );
  }
}
