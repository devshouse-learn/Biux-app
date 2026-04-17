import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:biux/features/social/data/models/comment_model.dart';

/// Datasource para comentarios en Firebase Realtime Database
class CommentsRealtimeDatasource {
  final FirebaseDatabase _database;

  CommentsRealtimeDatasource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Obtiene la ruta base según el tipo
  String _getBasePath(String type) {
    switch (type) {
      case 'post':
        return 'comments/posts';
      case 'ride':
        return 'comments/rides';
      default:
        return 'comments/posts';
    }
  }

  /// Stream de comentarios de un contenido
  Stream<List<CommentModel>> watchComments(String type, String targetId) {
    final ref = _database.ref('${_getBasePath(type)}/$targetId');

    return ref.orderByChild('createdAt').onValue.map((event) {
      if (event.snapshot.value == null) return <CommentModel>[];

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final comments = <CommentModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          final comment = CommentModel.fromJson(key, value);
          // Solo comentarios principales (sin parentCommentId) y que NO estén eliminados
          if (comment.parentCommentId == null && !comment.isDeleted) {
            comments.add(comment);
          }
        }
      });

      // Ordenar por fecha de creación ascendente
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return comments;
    });
  }

  /// Stream de respuestas a un comentario
  Stream<List<CommentModel>> watchReplies(
    String type,
    String targetId,
    String parentCommentId,
  ) {
    final ref = _database.ref('${_getBasePath(type)}/$targetId');

    return ref
        .orderByChild('parentCommentId')
        .equalTo(parentCommentId)
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return <CommentModel>[];

          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final replies = <CommentModel>[];

          data.forEach((key, value) {
            if (value is Map) {
              final reply = CommentModel.fromJson(key, value);
              // Filtrar respuestas eliminadas
              if (!reply.isDeleted) {
                replies.add(reply);
              }
            }
          });

          // Ordenar por fecha de creación ascendente
          replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return replies;
        });
  }

  /// Stream del conteo de comentarios
  Stream<int> watchCommentsCount(String type, String targetId) {
    return watchComments(type, targetId).map((comments) => comments.length);
  }

  /// Crea un nuevo comentario
  Future<String> createComment({
    required String type,
    required String targetId,
    required CommentModel comment,
  }) async {
    final ref = _database.ref('${_getBasePath(type)}/$targetId').push();
    final commentId = ref.key!;

    // Crear el modelo con el ID generado
    final commentWithId = CommentModel(
      id: commentId,
      userId: comment.userId,
      userName: comment.userName,
      userPhoto: comment.userPhoto,
      text: comment.text,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      likesCount: comment.likesCount,
      repliesCount: comment.repliesCount,
      isEdited: comment.isEdited,
      isDeleted: comment.isDeleted,
      parentCommentId: comment.parentCommentId,
      mentions: comment.mentions,
    );

    // Debug: Ver qué datos estamos enviando
    final jsonData = commentWithId.toJson();

    // IMPORTANTE: Usar timestamp del servidor en lugar del cliente
    jsonData['createdAt'] = ServerValue.timestamp;

    debugPrint('🔍 Creando comentario en: ${ref.path}');
    debugPrint('🔍 UserId del comentario: ${comment.userId}');

    // CRÍTICO: Verificar que el usuario esté autenticado
    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint('👤 Usuario actual en Firebase Auth: ${currentUser?.uid}');
    debugPrint('🎫 ¿Tiene token?: ${currentUser != null}');
    if (currentUser != null) {
      final token = await currentUser.getIdToken();
      debugPrint('🎫 Token ID (primeros 50 chars): ${token?.substring(0, 50)}');
    }

    debugPrint('📝 Escribiendo comentario en Realtime Database...');
    debugPrint('   Datos: $jsonData');
    try {
      await ref.set(jsonData);
      debugPrint('✅ Comentario creado exitosamente: $commentId');
    } catch (e) {
      debugPrint('❌ Error al crear comentario: $e');
      debugPrint('❌ Path: ${ref.path}');
      if (e is PlatformException) {
        debugPrint('❌ Code: ${e.code}');
        debugPrint('❌ Message: ${e.message}');
      }
      rethrow;
    }

    // Si es una respuesta, incrementar el contador de respuestas del padre
    if (comment.parentCommentId != null) {
      try {
        debugPrint('🔢 Actualizando contador de respuestas del padre...');
        final parentRef = _database.ref(
          '${_getBasePath(type)}/$targetId/${comment.parentCommentId}/repliesCount',
        );
        final snapshot = await parentRef.get();
        final currentCount = snapshot.value as int? ?? 0;
        await parentRef.set(currentCount + 1);
        debugPrint(
          '✅ Contador actualizado: $currentCount -> ${currentCount + 1}',
        );
      } catch (counterError) {
        // No fallar si el contador no se puede actualizar
        debugPrint(
          '⚠️ No se pudo actualizar contador de respuestas: $counterError',
        );
        // El comentario ya fue creado exitosamente, esto es solo metadata
      }
    }

    return ref.key!;
  }

  /// Actualiza un comentario
  Future<void> updateComment({
    required String type,
    required String targetId,
    required String commentId,
    required String newText,
  }) async {
    final ref = _database.ref('${_getBasePath(type)}/$targetId/$commentId');
    final now = DateTime.now().millisecondsSinceEpoch;

    await ref.update({'text': newText, 'updatedAt': now, 'isEdited': true});
  }

  /// Elimina un comentario (soft delete)
  Future<void> deleteComment({
    required String type,
    required String targetId,
    required String commentId,
  }) async {
    final ref = _database.ref('${_getBasePath(type)}/$targetId/$commentId');

    debugPrint('🗑️ Eliminando comentario (soft delete)');
    debugPrint('   Path: ${ref.path}');
    debugPrint('   CommentId: $commentId');

    try {
      // Soft delete: marcar como eliminado en lugar de borrar
      // Usar update en su lugar para mejor manejo de permisos
      final updateData = {
        'isDeleted': true,
        'text': '[Eliminado]',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await ref.update(updateData);
      debugPrint('✅ Comentario marcado como eliminado en Firebase');
    } catch (e) {
      debugPrint('❌ Error al actualizar en Firebase: $e');

      // Si el error es de permisos, intentar eliminación alternativa
      if (e.toString().contains('Permission denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('🔄 Intentando eliminación completa...');
        try {
          await ref.remove();
          debugPrint('✅ Comentario eliminado completamente');
        } catch (e2) {
          debugPrint('❌ Error en eliminación alternativa: $e2');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Obtiene un comentario específico
  Future<CommentModel?> getComment({
    required String type,
    required String targetId,
    required String commentId,
  }) async {
    final ref = _database.ref('${_getBasePath(type)}/$targetId/$commentId');
    debugPrint('🔍 Obteniendo comentario de: ${ref.path}');

    final snapshot = await ref.get();

    debugPrint('   Snapshot existe: ${snapshot.exists}');
    if (!snapshot.exists) {
      debugPrint('   ⚠️ Comentario no encontrado en base de datos');
      return null;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    debugPrint('   Datos: $data');

    final comment = CommentModel.fromJson(commentId, data);
    debugPrint('   CommentModel creado - UserId: ${comment.userId}');

    return comment;
  }

  /// Incrementa el contador de likes de un comentario
  Future<void> incrementLikesCount({
    required String type,
    required String targetId,
    required String commentId,
  }) async {
    final ref = _database.ref(
      '${_getBasePath(type)}/$targetId/$commentId/likesCount',
    );
    final snapshot = await ref.get();
    final currentCount = snapshot.value as int? ?? 0;
    await ref.set(currentCount + 1);
  }

  /// Decrementa el contador de likes de un comentario
  Future<void> decrementLikesCount({
    required String type,
    required String targetId,
    required String commentId,
  }) async {
    final ref = _database.ref(
      '${_getBasePath(type)}/$targetId/$commentId/likesCount',
    );
    final snapshot = await ref.get();
    final currentCount = snapshot.value as int? ?? 0;
    if (currentCount > 0) {
      await ref.set(currentCount - 1);
    }
  }
}
