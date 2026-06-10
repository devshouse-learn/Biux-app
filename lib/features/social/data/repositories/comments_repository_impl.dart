import 'package:flutter/foundation.dart';
import 'package:biux/features/social/domain/entities/comment_entity.dart';
import 'package:biux/features/social/domain/repositories/comments_repository.dart';
import 'package:biux/features/social/data/datasources/comments_realtime_datasource.dart';
import 'package:biux/features/social/data/models/comment_model.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/app_logger.dart';

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
    try {
      // CRÍTICO #5: Verificar ownership y manejar casos de inconsistencia
      final comment = await _datasource.getComment(
        type: _typeToString(type),
        targetId: targetId,
        commentId: commentId,
      );

      if (comment == null) {
        AppLogger.warning('Intento de actualizar comentario eliminado: $commentId',
            tag: 'CommentsRepositoryImpl');
        throw ResourceNotFoundException('Comentario');
      }

      if (comment.userId != userId) {
        AppLogger.warning(
            'Intento de actualizar comentario ajeno - Usuario: $userId, Propietario: ${comment.userId}',
            tag: 'CommentsRepositoryImpl');
        throw UnauthorizedException('editar este comentario');
      }

      // Actualizar comentario
      await _datasource.updateComment(
        type: _typeToString(type),
        targetId: targetId,
        commentId: commentId,
        newText: newText,
      );

      AppLogger.info('Comentario actualizado: $commentId', tag: 'CommentsRepositoryImpl');
    } on UnauthorizedException catch (e) {
      AppLogger.warning('Operación no autorizada: ${e.message}',
          tag: 'CommentsRepositoryImpl');
      rethrow;
    } on ResourceNotFoundException catch (e) {
      AppLogger.warning('Recurso no encontrado: ${e.message}',
          tag: 'CommentsRepositoryImpl');
      rethrow;
    } catch (e) {
      AppLogger.error('Error actualizando comentario: $e',
          tag: 'CommentsRepositoryImpl', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
    required String userId,
  }) async {
    // Verificar que el usuario es el autor
    debugPrint('🔍 Verificando eliminación de comentario:');
    debugPrint('   CommentId: $commentId');
    debugPrint('   UserId actual: $userId');

    final comment = await _datasource.getComment(
      type: _typeToString(type),
      targetId: targetId,
      commentId: commentId,
    );

    debugPrint('   Comentario encontrado: ${comment != null}');
    if (comment != null) {
      debugPrint('   UserId del comentario: ${comment.userId}');
    }

    if (comment == null) {
      throw Exception('El comentario no existe');
    }

    if (comment.userId != userId) {
      throw Exception(
        'No tienes permiso para eliminar este comentario. Tu ID: $userId, Propietario: ${comment.userId}',
      );
    }

    debugPrint('✅ Autorización verificada, procediendo a eliminar');
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
