import 'package:firebase_database/firebase_database.dart';
import 'package:biux/features/social/data/models/attendee_model.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

/// Datasource para asistentes en Firebase Realtime Database
class AttendeesRealtimeDatasource {
  final FirebaseDatabase _database;

  AttendeesRealtimeDatasource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// ALTO: Validar entrada y agregar error handling
  /// Stream de asistentes a una rodada
  Stream<List<AttendeeModel>> watchAttendees(String rideId) {
    if (rideId.isEmpty) {
      AppLogger.warning('Ride ID vacío en watchAttendees',
          tag: 'AttendeesRealtimeDatasource');
      return const Stream.empty();
    }

    final ref = _database.ref('rides/attendees/$rideId');

    return ref.onValue.map((event) {
      if (event.snapshot.value == null) {
        AppLogger.debug('Sin asistentes para rodada: $rideId',
            tag: 'AttendeesRealtimeDatasource');
        return <AttendeeModel>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final attendees = <AttendeeModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          attendees.add(AttendeeModel.fromJson(key, value));
        }
      });

      // Ordenar por fecha de registro ascendente
      attendees.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

      AppLogger.debug('Asistentes cargados: ${attendees.length}',
          tag: 'AttendeesRealtimeDatasource');
      return attendees;
    }).handleError((e) {
      AppLogger.error('Error en watchAttendees: $e',
          tag: 'AttendeesRealtimeDatasource', error: e);
      return [];
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

  /// ALTO: Validar entrada y agregar logging
  /// Registra asistencia a una rodada
  Future<void> joinRide({
    required String rideId,
    required AttendeeModel attendee,
  }) async {
    try {
      if (rideId.isEmpty || attendee.userId.isEmpty) {
        throw ValidationException('ids',
            'Ride ID y attendee User ID son requeridos');
      }

      final ref = _database.ref('rides/attendees/$rideId/${attendee.userId}');
      await ref.set(attendee.toJson());

      AppLogger.info('Usuario se unió a rodada: $rideId',
          tag: 'AttendeesRealtimeDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AttendeesRealtimeDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error en joinRide: $e',
          tag: 'AttendeesRealtimeDatasource', error: e);
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  /// Actualiza el estado de asistencia
  Future<void> updateAttendanceStatus({
    required String rideId,
    required String userId,
    required String status,
  }) async {
    try {
      if (rideId.isEmpty || userId.isEmpty || status.isEmpty) {
        throw ValidationException('ids',
            'Ride ID, User ID y status son requeridos');
      }

      const validStatuses = ['confirmed', 'maybe', 'cancelled'];
      if (!validStatuses.contains(status)) {
        throw ValidationException('status',
            'Status debe ser: confirmed, maybe o cancelled');
      }

      final ref = _database.ref('rides/attendees/$rideId/$userId/status');
      await ref.set(status);

      AppLogger.info('Status actualizado: $status',
          tag: 'AttendeesRealtimeDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AttendeesRealtimeDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error en updateAttendanceStatus: $e',
          tag: 'AttendeesRealtimeDatasource', error: e);
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  /// Cancela la asistencia a una rodada
  Future<void> leaveRide({
    required String rideId,
    required String userId,
  }) async {
    try {
      if (rideId.isEmpty || userId.isEmpty) {
        throw ValidationException('ids',
            'Ride ID y User ID son requeridos');
      }

      final ref = _database.ref('rides/attendees/$rideId/$userId');
      await ref.remove();

      AppLogger.info('Usuario salió de rodada: $rideId',
          tag: 'AttendeesRealtimeDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AttendeesRealtimeDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error en leaveRide: $e',
          tag: 'AttendeesRealtimeDatasource', error: e);
      rethrow;
    }
  }

  /// ALTO: Validar entrada y error handling
  /// Obtiene la información de un asistente específico
  Future<AttendeeModel?> getAttendee({
    required String rideId,
    required String userId,
  }) async {
    try {
      if (rideId.isEmpty || userId.isEmpty) {
        throw ValidationException('ids',
            'Ride ID y User ID son requeridos');
      }

      final ref = _database.ref('rides/attendees/$rideId/$userId');
      final snapshot = await ref.get();

      if (snapshot.value == null) {
        AppLogger.warning('Asistente no encontrado: $userId',
            tag: 'AttendeesRealtimeDatasource');
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return AttendeeModel.fromJson(userId, data);
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AttendeesRealtimeDatasource');
      return null;
    } catch (e) {
      AppLogger.error('Error en getAttendee: $e',
          tag: 'AttendeesRealtimeDatasource', error: e);
      return null;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  /// Obtiene todos los asistentes de una rodada (snapshot único)
  Future<List<AttendeeModel>> getAttendees(String rideId) async {
    try {
      if (rideId.isEmpty) {
        throw ValidationException('rideId', 'Ride ID no puede estar vacío');
      }

      final ref = _database.ref('rides/attendees/$rideId');
      final snapshot = await ref.get();

      if (snapshot.value == null) {
        AppLogger.debug('Sin asistentes para rodada: $rideId',
            tag: 'AttendeesRealtimeDatasource');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final attendees = <AttendeeModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          attendees.add(AttendeeModel.fromJson(key, value));
        }
      });

      attendees.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

      AppLogger.debug('Asistentes obtenidos: ${attendees.length}',
          tag: 'AttendeesRealtimeDatasource');
      return attendees;
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'AttendeesRealtimeDatasource');
      return [];
    } catch (e) {
      AppLogger.error('Error en getAttendees: $e',
          tag: 'AttendeesRealtimeDatasource', error: e);
      return [];
    }
  }
}
