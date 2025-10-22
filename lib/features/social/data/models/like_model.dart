import '../../domain/entities/like_entity.dart';

/// Modelo de like para Firebase Realtime Database
class LikeModel {
  final String userId;
  final String userName;
  final String? userPhoto;
  final int timestamp;
  final int? expiresAt;

  const LikeModel({
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.timestamp,
    this.expiresAt,
  });

  /// Convierte de JSON (Firebase) a modelo
  factory LikeModel.fromJson(String userId, Map<dynamic, dynamic> json) {
    return LikeModel(
      userId: userId,
      userName: json['userName'] as String? ?? '',
      userPhoto: json['userPhoto'] as String?,
      timestamp: json['timestamp'] as int? ?? 0,
      expiresAt: json['expiresAt'] as int?,
    );
  }

  /// Convierte de modelo a JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // ⚠️ REQUERIDO por las reglas de Firebase
      'userName': userName,
      if (userPhoto != null) 'userPhoto': userPhoto,
      'timestamp': timestamp,
      if (expiresAt != null) 'expiresAt': expiresAt,
    };
  }

  /// Convierte de modelo a entidad
  LikeEntity toEntity() {
    return LikeEntity(
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      expiresAt: expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(expiresAt!)
          : null,
    );
  }

  /// Convierte de entidad a modelo
  factory LikeModel.fromEntity(LikeEntity entity) {
    return LikeModel(
      userId: entity.userId,
      userName: entity.userName,
      userPhoto: entity.userPhoto,
      timestamp: entity.timestamp.millisecondsSinceEpoch,
      expiresAt: entity.expiresAt?.millisecondsSinceEpoch,
    );
  }
}
