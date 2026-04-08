import 'package:biux/features/social/domain/entities/attendee_entity.dart';
import 'package:biux/features/social/domain/repositories/attendees_repository.dart';
import 'package:biux/features/social/data/datasources/attendees_realtime_datasource.dart';
import 'package:biux/features/social/data/models/attendee_model.dart';

/// Implementación del repositorio de asistentes
class AttendeesRepositoryImpl implements AttendeesRepository {
  final AttendeesRealtimeDatasource _datasource;

  AttendeesRepositoryImpl({AttendeesRealtimeDatasource? datasource})
    : _datasource = datasource ?? AttendeesRealtimeDatasource();

  @override
  Stream<List<AttendeeEntity>> watchAttendees(String rideId) {
    return _datasource
        .watchAttendees(rideId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<int> watchConfirmedCount(String rideId) {
    return _datasource.watchConfirmedCount(rideId);
  }

  @override
  Stream<bool> watchUserIsAttending(String rideId, String userId) {
    return _datasource.watchUserIsAttending(rideId, userId);
  }

  @override
  Stream<AttendeeStatus?> watchUserAttendanceStatus(
    String rideId,
    String userId,
  ) {
    return _datasource
        .watchUserAttendanceStatus(rideId, userId)
        .map(
          (status) => status != null ? AttendeeStatus.fromString(status) : null,
        );
  }

  @override
  Future<void> joinRide({
    required String rideId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? fullName,
    String? bikeType,
    CyclingLevel? level,
    AttendeeStatus status = AttendeeStatus.confirmed,
  }) {
    final attendee = AttendeeModel(
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      fullName: fullName,
      bikeType: bikeType,
      level: level?.value,
      joinedAt: DateTime.now().millisecondsSinceEpoch,
      status: status.value,
      canEdit: true,
    );

    return _datasource.joinRide(rideId: rideId, attendee: attendee);
  }

  @override
  Future<void> updateAttendanceStatus({
    required String rideId,
    required String userId,
    required AttendeeStatus status,
  }) {
    return _datasource.updateAttendanceStatus(
      rideId: rideId,
      userId: userId,
      status: status.value,
    );
  }

  @override
  Future<void> leaveRide({required String rideId, required String userId}) {
    return _datasource.leaveRide(rideId: rideId, userId: userId);
  }

  @override
  Future<AttendeeEntity?> getAttendee({
    required String rideId,
    required String userId,
  }) async {
    final model = await _datasource.getAttendee(rideId: rideId, userId: userId);

    return model?.toEntity();
  }
}
