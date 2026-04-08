import 'package:firebase_database/firebase_database.dart';
import 'package:biux/features/social/data/models/attendee_model.dart';

/// Datasource para asistentes en Firebase Realtime Database
class AttendeesRealtimeDatasource {
  final FirebaseDatabase _database;

  AttendeesRealtimeDatasource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Stream de asistentes a una rodada
  Stream<List<AttendeeModel>> watchAttendees(String rideId) {
    final ref = _database.ref('rides/attendees/$rideId');

    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return <AttendeeModel>[];

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final attendees = <AttendeeModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          attendees.add(AttendeeModel.fromJson(key, value));
        }
      });

      // Ordenar por fecha de registro ascendente
      attendees.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

      return attendees;
    });
  }

  /// Stream del conteo de asistentes confirmados
  Stream<int> watchConfirmedCount(String rideId) {
    return watchAttendees(rideId).map((attendees) {
      return attendees.where((a) => a.status == 'confirmed').length;
    });
  }

  /// Stream para verificar si el usuario está registrado
  Stream<bool> watchUserIsAttending(String rideId, String userId) {
    final ref = _database.ref('rides/attendees/$rideId/$userId');

    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return false;

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final status = data['status'] as String? ?? 'confirmed';

      // Solo se considera asistiendo si está confirmado o "maybe"
      return status != 'cancelled';
    });
  }

  /// Stream del estado de asistencia del usuario
  Stream<String?> watchUserAttendanceStatus(String rideId, String userId) {
    final ref = _database.ref('rides/attendees/$rideId/$userId/status');

    return ref.onValue.map((event) {
      return event.snapshot.value as String?;
    });
  }

  /// Registra asistencia a una rodada
  Future<void> joinRide({
    required String rideId,
    required AttendeeModel attendee,
  }) async {
    final ref = _database.ref('rides/attendees/$rideId/${attendee.userId}');
    await ref.set(attendee.toJson());
  }

  /// Actualiza el estado de asistencia
  Future<void> updateAttendanceStatus({
    required String rideId,
    required String userId,
    required String status,
  }) async {
    final ref = _database.ref('rides/attendees/$rideId/$userId/status');
    await ref.set(status);
  }

  /// Cancela la asistencia a una rodada
  Future<void> leaveRide({
    required String rideId,
    required String userId,
  }) async {
    final ref = _database.ref('rides/attendees/$rideId/$userId');
    await ref.remove();
  }

  /// Obtiene la información de un asistente específico
  Future<AttendeeModel?> getAttendee({
    required String rideId,
    required String userId,
  }) async {
    final ref = _database.ref('rides/attendees/$rideId/$userId');
    final snapshot = await ref.get();

    if (snapshot.value == null) return null;

    final data = snapshot.value as Map<dynamic, dynamic>;
    return AttendeeModel.fromJson(userId, data);
  }

  /// Obtiene todos los asistentes de una rodada (snapshot único)
  Future<List<AttendeeModel>> getAttendees(String rideId) async {
    final ref = _database.ref('rides/attendees/$rideId');
    final snapshot = await ref.get();

    if (snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    final attendees = <AttendeeModel>[];

    data.forEach((key, value) {
      if (value is Map) {
        attendees.add(AttendeeModel.fromJson(key, value));
      }
    });

    attendees.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    return attendees;
  }
}
