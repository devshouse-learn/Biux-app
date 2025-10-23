import '../../domain/entities/like_entity.dart';
import '../../domain/repositories/likes_repository.dart';
import '../datasources/likes_realtime_datasource.dart';
import '../models/like_model.dart';
import 'package:firebase_database/firebase_database.dart';

/// Implementación del repositorio de likes
class LikesRepositoryImpl implements LikesRepository {
  final LikesRealtimeDatasource _datasource;

  LikesRepositoryImpl({LikesRealtimeDatasource? datasource})
    : _datasource = datasource ?? LikesRealtimeDatasource();

  /// Convierte el tipo de enum a string
  String _typeToString(LikeableType type) {
    switch (type) {
      case LikeableType.post:
        return 'post';
      case LikeableType.comment:
        return 'comment';
      case LikeableType.story:
        return 'story';
    }
  }

  @override
  Stream<List<LikeEntity>> watchLikes(LikeableType type, String targetId) {
    return _datasource
        .watchLikes(_typeToString(type), targetId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<int> watchLikesCount(LikeableType type, String targetId) {
    return _datasource.watchLikesCount(_typeToString(type), targetId);
  }

  @override
  Stream<bool> watchUserLiked(
    LikeableType type,
    String targetId,
    String userId,
  ) {
    return _datasource.watchUserLiked(_typeToString(type), targetId, userId);
  }

  @override
  Future<void> like({
    required LikeableType type,
    required String targetId,
    required String userId,
    required String userName,
    String? userPhoto,
    DateTime? expiresAt,
  }) {
    final like = LikeModel(
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      timestamp: ServerValue.timestamp, // ✅ Usar timestamp del servidor
      expiresAt: expiresAt?.millisecondsSinceEpoch,
    );

    print('🔍 DEBUG LIKE - Type: ${_typeToString(type)}');
    print('🔍 DEBUG LIKE - TargetId: $targetId');
    print('🔍 DEBUG LIKE - UserId: $userId');
    print('🔍 DEBUG LIKE - UserName: "$userName"');
    print('🔍 DEBUG LIKE - UserPhoto: $userPhoto');
    print('🔍 DEBUG LIKE - Timestamp: ServerValue.timestamp');
    print('🔍 DEBUG LIKE - ExpiresAt: ${like.expiresAt}');
    print('🔍 DEBUG LIKE - JSON: ${like.toJson()}');

    return _datasource.like(
      type: _typeToString(type),
      targetId: targetId,
      like: like,
    );
  }

  @override
  Future<void> unlike({
    required LikeableType type,
    required String targetId,
    required String userId,
  }) {
    return _datasource.unlike(
      type: _typeToString(type),
      targetId: targetId,
      userId: userId,
    );
  }

  @override
  Future<void> toggleLike({
    required LikeableType type,
    required String targetId,
    required String userId,
    required String userName,
    String? userPhoto,
    DateTime? expiresAt,
  }) async {
    final existingLike = await _datasource.getLike(
      type: _typeToString(type),
      targetId: targetId,
      userId: userId,
    );

    if (existingLike != null) {
      await unlike(type: type, targetId: targetId, userId: userId);
    } else {
      await like(
        type: type,
        targetId: targetId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        expiresAt: expiresAt,
      );
    }
  }
}
