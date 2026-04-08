import 'package:biux/features/social/domain/entities/like_entity.dart';

/// Tipos de contenido que pueden recibir likes
enum LikeableType { post, comment, story }

/// Repositorio de likes (interfaz)
abstract class LikesRepository {
  /// Stream de usuarios que dieron like a un contenido
  Stream<List<LikeEntity>> watchLikes(LikeableType type, String targetId);

  /// Obtiene el conteo de likes
  Stream<int> watchLikesCount(LikeableType type, String targetId);

  /// Verifica si el usuario actual dio like
  Stream<bool> watchUserLiked(
    LikeableType type,
    String targetId,
    String userId,
  );

  /// Da like a un contenido
  Future<void> like({
    required LikeableType type,
    required String targetId,
    required String userId,
    required String userName,
    String? userPhoto,
    DateTime? expiresAt, // Solo para stories (24h)
  });

  /// Quita el like de un contenido
  Future<void> unlike({
    required LikeableType type,
    required String targetId,
    required String userId,
  });

  /// Toggle like (da o quita según el estado actual)
  Future<void> toggleLike({
    required LikeableType type,
    required String targetId,
    required String userId,
    required String userName,
    String? userPhoto,
    DateTime? expiresAt,
  });
}
