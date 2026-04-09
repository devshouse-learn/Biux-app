import 'package:biux/features/social/domain/entities/attendee_entity.dart';

/// Repositorio de asistentes (interfaz)
abstract class AttendeesRepository {
  /// Stream de asistentes a una rodada
  Stream<List<AttendeeEntity>> watchAttendees(String rideId);

  /// Obtiene el conteo de asistentes confirmados
  Stream<int> watchConfirmedCount(String rideId);

  /// Verifica si el usuario está registrado como asistente
  Stream<bool> watchUserIsAttending(String rideId, String userId);

  /// Obtiene el estado de asistencia del usuario
  Stream<AttendeeStatus?> watchUserAttendanceStatus(
    String rideId,
    String userId,
  );

  /// Registra asistencia a una rodada
  Future<void> joinRide({
    required String rideId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? fullName,
    String? bikeType,
    CyclingLevel? level,
    AttendeeStatus status = AttendeeStatus.confirmed,
  });

  /// Actualiza el estado de asistencia
  Future<void> updateAttendanceStatus({
    required String rideId,
    required String userId,
    required AttendeeStatus status,
  });

  /// Cancela la asistencia a una rodada
  Future<void> leaveRide({required String rideId, required String userId});

  /// Obtiene la información de un asistente específico
  Future<AttendeeEntity?> getAttendee({
    required String rideId,
    required String userId,
  });
}
