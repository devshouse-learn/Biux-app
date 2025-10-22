import '../entities/comment_entity.dart';

/// Tipos de contenido que pueden recibir comentarios
enum CommentableType { post, ride }

/// Repositorio de comentarios (interfaz)
abstract class CommentsRepository {
  /// Stream de comentarios de un contenido
  Stream<List<CommentEntity>> watchComments(
    CommentableType type,
    String targetId,
  );

  /// Stream de respuestas a un comentario
  Stream<List<CommentEntity>> watchReplies(
    CommentableType type,
    String targetId,
    String parentCommentId,
  );

  /// Obtiene el conteo de comentarios
  Stream<int> watchCommentsCount(CommentableType type, String targetId);

  /// Crea un nuevo comentario
  Future<String> createComment({
    required CommentableType type,
    required String targetId,
    required String userId,
    required String userName,
    String? userPhoto,
    required String text,
    String? parentCommentId,
  });

  /// Actualiza un comentario existente
  Future<void> updateComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
    required String userId,
    required String newText,
  });

  /// Elimina un comentario
  Future<void> deleteComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
    required String userId,
  });

  /// Obtiene un comentario específico
  Future<CommentEntity?> getComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
  });
}
