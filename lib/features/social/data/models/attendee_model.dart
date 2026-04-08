import 'package:biux/features/social/domain/entities/attendee_entity.dart';

/// Modelo de asistente para Firebase Realtime Database
class AttendeeModel {
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? fullName;
  final String? bikeType;
  final String? level;
  final int joinedAt;
  final String status;
  final bool canEdit;

  const AttendeeModel({
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.fullName,
    this.bikeType,
    this.level,
    required this.joinedAt,
    required this.status,
    this.canEdit = false,
  });

  /// Convierte de JSON (Firebase) a modelo
  factory AttendeeModel.fromJson(String userId, Map<dynamic, dynamic> json) {
    return AttendeeModel(
      userId: userId,
      userName: json['userName'] as String? ?? '',
      userPhoto: json['userPhoto'] as String?,
      fullName: json['fullName'] as String?,
      bikeType: json['bikeType'] as String?,
      level: json['level'] as String?,
      joinedAt: json['joinedAt'] as int? ?? 0,
      status: json['status'] as String? ?? 'confirmed',
      canEdit: json['canEdit'] as bool? ?? false,
    );
  }

  /// Convierte de modelo a JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // ⚠️ REQUERIDO por las reglas de Firebase
      'userName': userName,
      if (userPhoto != null) 'userPhoto': userPhoto,
      if (fullName != null) 'fullName': fullName,
      if (bikeType != null) 'bikeType': bikeType,
      if (level != null) 'level': level,
      'joinedAt': joinedAt,
      'status': status,
      'canEdit': canEdit,
    };
  }

  /// Convierte de modelo a entidad
  AttendeeEntity toEntity() {
    return AttendeeEntity(
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      fullName: fullName,
      bikeType: bikeType,
      level: level != null ? CyclingLevel.fromString(level!) : null,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(joinedAt),
      status: AttendeeStatus.fromString(status),
      canEdit: canEdit,
    );
  }

  /// Convierte de entidad a modelo
  factory AttendeeModel.fromEntity(AttendeeEntity entity) {
    return AttendeeModel(
      userId: entity.userId,
      userName: entity.userName,
      userPhoto: entity.userPhoto,
      fullName: entity.fullName,
      bikeType: entity.bikeType,
      level: entity.level?.value,
      joinedAt: entity.joinedAt.millisecondsSinceEpoch,
      status: entity.status.value,
      canEdit: entity.canEdit,
    );
  }
}
