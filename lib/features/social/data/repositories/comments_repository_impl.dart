import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../datasources/comments_realtime_datasource.dart';
import '../models/comment_model.dart';

/// Implementación del repositorio de comentarios
class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRealtimeDatasource _datasource;

  CommentsRepositoryImpl({CommentsRealtimeDatasource? datasource})
    : _datasource = datasource ?? CommentsRealtimeDatasource();

  /// Convierte el tipo de enum a string
  String _typeToString(CommentableType type) {
    switch (type) {
      case CommentableType.post:
        return 'post';
      case CommentableType.ride:
        return 'ride';
    }
  }

  /// Extrae menciones del texto (@usuario)
  List<String> _extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)!).toSet().toList();
  }

  @override
  Stream<List<CommentEntity>> watchComments(
    CommentableType type,
    String targetId,
  ) {
    return _datasource
        .watchComments(_typeToString(type), targetId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<CommentEntity>> watchReplies(
    CommentableType type,
    String targetId,
    String parentCommentId,
  ) {
    return _datasource
        .watchReplies(_typeToString(type), targetId, parentCommentId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<int> watchCommentsCount(CommentableType type, String targetId) {
    return _datasource.watchCommentsCount(_typeToString(type), targetId);
  }

  @override
  Future<String> createComment({
    required CommentableType type,
    required String targetId,
    required String userId,
    required String userName,
    String? userPhoto,
    required String text,
    String? parentCommentId,
  }) {
    final mentions = _extractMentions(text);

    final comment = CommentModel(
      id: '', // Se generará automáticamente en el datasource
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      parentCommentId: parentCommentId,
      mentions: mentions,
    );

    return _datasource.createComment(
      type: _typeToString(type),
      targetId: targetId,
      comment: comment,
    );
  }

  @override
  Future<void> updateComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
    required String userId,
    required String newText,
  }) async {
    // Verificar que el usuario es el autor
    final comment = await _datasource.getComment(
      type: _typeToString(type),
      targetId: targetId,
      commentId: commentId,
    );

    if (comment == null || comment.userId != userId) {
      throw Exception('No tienes permiso para editar este comentario');
    }

    return _datasource.updateComment(
      type: _typeToString(type),
      targetId: targetId,
      commentId: commentId,
      newText: newText,
    );
  }

  @override
  Future<void> deleteComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
    required String userId,
  }) async {
    // Verificar que el usuario es el autor
    final comment = await _datasource.getComment(
      type: _typeToString(type),
      targetId: targetId,
      commentId: commentId,
    );

    if (comment == null || comment.userId != userId) {
      throw Exception('No tienes permiso para eliminar este comentario');
    }

    return _datasource.deleteComment(
      type: _typeToString(type),
      targetId: targetId,
      commentId: commentId,
    );
  }

  @override
  Future<CommentEntity?> getComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
  }) async {
    final model = await _datasource.getComment(
      type: _typeToString(type),
      targetId: targetId,
      commentId: commentId,
    );

    return model?.toEntity();
  }
}
