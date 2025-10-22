/// Estado de asistencia a una rodada
enum AttendeeStatus {
  confirmed('confirmed'),
  maybe('maybe'),
  cancelled('cancelled');

  final String value;
  const AttendeeStatus(this.value);

  static AttendeeStatus fromString(String value) {
    return AttendeeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendeeStatus.confirmed,
    );
  }
}

/// Nivel de ciclismo del asistente
enum CyclingLevel {
  beginner('beginner'),
  intermediate('intermediate'),
  advanced('advanced');

  final String value;
  const CyclingLevel(this.value);

  static CyclingLevel fromString(String value) {
    return CyclingLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => CyclingLevel.intermediate,
    );
  }

  String get displayName {
    switch (this) {
      case CyclingLevel.beginner:
        return 'Principiante';
      case CyclingLevel.intermediate:
        return 'Intermedio';
      case CyclingLevel.advanced:
        return 'Avanzado';
    }
  }
}

/// Entidad de asistente a rodada
class AttendeeEntity {
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? fullName;
  final String? bikeType;
  final CyclingLevel? level;
  final DateTime joinedAt;
  final AttendeeStatus status;
  final bool canEdit;

  const AttendeeEntity({
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

  /// Verifica si la asistencia está confirmada
  bool get isConfirmed => status == AttendeeStatus.confirmed;

  /// Verifica si la asistencia está cancelada
  bool get isCancelled => status == AttendeeStatus.cancelled;

  /// Obtiene el ícono según el estado
  String get statusIcon {
    switch (status) {
      case AttendeeStatus.confirmed:
        return '✓';
      case AttendeeStatus.maybe:
        return '?';
      case AttendeeStatus.cancelled:
        return '✗';
    }
  }

  /// Crea una copia con campos modificados
  AttendeeEntity copyWith({
    String? userId,
    String? userName,
    String? userPhoto,
    String? fullName,
    String? bikeType,
    CyclingLevel? level,
    DateTime? joinedAt,
    AttendeeStatus? status,
    bool? canEdit,
  }) {
    return AttendeeEntity(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      fullName: fullName ?? this.fullName,
      bikeType: bikeType ?? this.bikeType,
      level: level ?? this.level,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
      canEdit: canEdit ?? this.canEdit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendeeEntity && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
