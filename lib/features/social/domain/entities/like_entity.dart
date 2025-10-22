/// Entidad de "Me gusta"
class LikeEntity {
  final String userId;
  final String userName;
  final String? userPhoto;
  final DateTime timestamp;
  final DateTime? expiresAt; // Solo para stories

  const LikeEntity({
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.timestamp,
    this.expiresAt,
  });

  /// Verifica si el like ha expirado (para stories)
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Crea una copia con campos modificados
  LikeEntity copyWith({
    String? userId,
    String? userName,
    String? userPhoto,
    DateTime? timestamp,
    DateTime? expiresAt,
  }) {
    return LikeEntity(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LikeEntity &&
        other.userId == userId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => userId.hashCode ^ timestamp.hashCode;
}
