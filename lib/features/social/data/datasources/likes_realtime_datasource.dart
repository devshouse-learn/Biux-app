import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/like_model.dart';

/// Datasource para likes en Firebase Realtime Database
class LikesRealtimeDatasource {
  final FirebaseDatabase _database;

  LikesRealtimeDatasource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Obtiene la ruta base según el tipo
  String _getBasePath(String type) {
    switch (type) {
      case 'post':
        return 'likes/posts';
      case 'comment':
        return 'likes/comments';
      case 'story':
        return 'likes/stories';
      default:
        return 'likes/posts';
    }
  }

  /// Stream de likes de un contenido
  Stream<List<LikeModel>> watchLikes(String type, String targetId) {
    final ref = _database.ref('${_getBasePath(type)}/$targetId');

    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return <LikeModel>[];

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final likes = <LikeModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          final like = LikeModel.fromJson(key, value);
          // Filtrar likes expirados (stories)
          if (like.expiresAt == null ||
              DateTime.now().millisecondsSinceEpoch < like.expiresAt!) {
            likes.add(like);
          }
        }
      });

      // Ordenar por timestamp descendente
      likes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return likes;
    });
  }

  /// Stream del conteo de likes
  Stream<int> watchLikesCount(String type, String targetId) {
    return watchLikes(type, targetId).map((likes) => likes.length);
  }

  /// Stream para verificar si el usuario dio like
  Stream<bool> watchUserLiked(String type, String targetId, String userId) {
    final ref = _database.ref('${_getBasePath(type)}/$targetId/$userId');

    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return false;

      // Verificar si está expirado (solo para stories)
      if (type == 'story') {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final expiresAt = data['expiresAt'] as int?;
        if (expiresAt != null &&
            DateTime.now().millisecondsSinceEpoch > expiresAt) {
          return false;
        }
      }

      return true;
    });
  }

  /// Da like a un contenido
  Future<void> like({
    required String type,
    required String targetId,
    required LikeModel like,
  }) async {
    final path = '${_getBasePath(type)}/$targetId/${like.userId}';
    final jsonData = like.toJson();

    print('🔍 DEBUG DATASOURCE - Path: $path');
    print('🔍 DEBUG DATASOURCE - JSON: $jsonData');

    // Verificar auth
    final currentUser = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG AUTH - currentUser.uid: ${currentUser?.uid}');
    print('🔍 DEBUG AUTH - like.userId: ${like.userId}');
    print('🔍 DEBUG AUTH - Match: ${currentUser?.uid == like.userId}');

    final ref = _database.ref(path);

    try {
      await ref.set(jsonData);
      print('✅ LIKE GUARDADO EXITOSAMENTE');
    } catch (e) {
      print('❌ ERROR AL GUARDAR LIKE: $e');
      rethrow;
    }
  }

  /// Quita el like de un contenido
  Future<void> unlike({
    required String type,
    required String targetId,
    required String userId,
  }) async {
    final ref = _database.ref('${_getBasePath(type)}/$targetId/$userId');
    await ref.remove();
  }

  /// Obtiene un like específico
  Future<LikeModel?> getLike({
    required String type,
    required String targetId,
    required String userId,
  }) async {
    final ref = _database.ref('${_getBasePath(type)}/$targetId/$userId');
    final snapshot = await ref.get();

    if (snapshot.value == null) return null;

    final data = snapshot.value as Map<dynamic, dynamic>;
    return LikeModel.fromJson(userId, data);
  }

  /// Limpia likes expirados (solo para stories)
  Future<void> cleanupExpiredLikes() async {
    final ref = _database.ref('likes/stories');
    final snapshot = await ref.get();

    if (snapshot.value == null) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updates = <String, dynamic>{};

    data.forEach((storyId, likes) {
      if (likes is Map) {
        likes.forEach((userId, likeData) {
          if (likeData is Map) {
            final expiresAt = likeData['expiresAt'] as int?;
            if (expiresAt != null && now > expiresAt) {
              updates['$storyId/$userId'] = null;
            }
          }
        });
      }
    });

    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }
}
