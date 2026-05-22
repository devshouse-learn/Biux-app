import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/social/domain/entities/like_entity.dart';
import 'package:biux/features/social/domain/repositories/likes_repository.dart';
import 'package:biux/features/social/domain/repositories/notifications_repository.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/domain/repositories/comments_repository.dart';

/// Provider para gestionar likes
class LikesProvider extends ChangeNotifier {
  final LikesRepository _repository;
  final NotificationsRepository _notificationsRepository;
  final String userId;

  // Variables para cachÃ© de datos del usuario
  String? _cachedUserName;
  String? _cachedUserPhoto;
  bool _userDataLoaded = false;

  LikesProvider({
    required LikesRepository repository,
    required NotificationsRepository notificationsRepository,
    required this.userId,
  }) : _repository = repository,
       _notificationsRepository = notificationsRepository;

  /// Obtiene los datos del usuario desde Firestore (se ejecuta una sola vez)
  Future<void> _loadUserData() async {
    if (_userDataLoaded) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _cachedUserName = 'Usuario';
        _cachedUserPhoto = null;
        _userDataLoaded = true;
        return;
      }

      // Obtener datos desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data();

      if (userData != null && userData.isNotEmpty) {
        String? name = userData['name'];
        String? username = userData['username'];
        String? phoneNumber = userData['phoneNumber'];

        _cachedUserName =
            (name != null && name.trim().isNotEmpty ? name : null) ??
            (username != null && username.trim().isNotEmpty
                ? username
                : null) ??
            currentUser.displayName ??
            (phoneNumber != null && phoneNumber.trim().isNotEmpty
                ? phoneNumber.replaceAll('phone_', '').replaceAll('+57', '')
                : null) ??
            currentUser.email?.split('@').first ??
            'Usuario';

        _cachedUserPhoto = userData['photoUrl'] ?? userData['photo'];
      } else {
        _cachedUserName =
            currentUser.displayName ??
            currentUser.phoneNumber
                ?.replaceAll('phone_', '')
                .replaceAll('+57', '') ??
            currentUser.email?.split('@').first ??
            'Usuario';
        _cachedUserPhoto = currentUser.photoURL;
      }

      _userDataLoaded = true;
    } on FirebaseException catch (e) {
      debugPrint('âš ï¸ Error cargando datos de usuario en LikesProvider: $e');
      _cachedUserName = 'Usuario';
      _cachedUserPhoto = null;
      _userDataLoaded = true;
    }
  }

  bool _isProcessing = false;
  String? _error;

  // Map para rastrear cooldown por targetId (tiempo de espera entre acciones)
  final Map<String, DateTime> _cooldowns = {};

  // DuraciÃ³n del cooldown (500ms para evitar spam pero permitir uso Ã¡gil)
  static const Duration _cooldownDuration = Duration(milliseconds: 500);

  bool get isProcessing => _isProcessing;
  String? get error => _error;

  /// Verifica si un target estÃ¡ en cooldown
  bool _isInCooldown(String targetId) {
    final lastAction = _cooldowns[targetId];
    if (lastAction == null) return false;

    final timeSinceLastAction = DateTime.now().difference(lastAction);
    return timeSinceLastAction < _cooldownDuration;
  }

  /// Marca el tiempo de la Ãºltima acciÃ³n
  void _setCooldown(String targetId) {
    _cooldowns[targetId] = DateTime.now();
  }

  /// Da like a un post
  Future<void> likePost({
    required String postId,
    required String postOwnerId,
    String? postPreview,
  }) async {
    await _toggleLike(
      type: LikeableType.post,
      targetId: postId,
      targetOwnerId: postOwnerId,
      targetPreview: postPreview,
      notificationType: NotificationType.likePost,
    );
  }

  /// Quita like de un post
  Future<void> unlikePost(String postId, {String? postOwnerId}) async {
    await _unlike(
      type: LikeableType.post,
      targetId: postId,
      targetOwnerId: postOwnerId,
    );
  }

  /// Da like a un comentario
  Future<void> likeComment({
    required String commentId,
    required String commentOwnerId,
    String? commentPreview,
    String? contextTargetId, // ID del post/ride donde estÃ¡ el comentario
    CommentableType? contextType, // Tipo: post o ride
  }) async {
    // Preparar metadata con el contexto del comentario
    final metadata = <String, dynamic>{};
    if (contextTargetId != null) {
      metadata['contextTargetId'] = contextTargetId;
    }
    if (contextType != null) {
      metadata['contextType'] = contextType == CommentableType.post
          ? 'post'
          : 'ride';
    }

    // Construir targetId compuesto para comentarios: type_targetId_commentId
    // Esto permite que la Cloud Function encuentre el comentario
    String finalTargetId = commentId;
    if (contextType != null && contextTargetId != null) {
      final typeStr = contextType == CommentableType.post ? 'post' : 'ride';
      finalTargetId = '${typeStr}_${contextTargetId}_$commentId';
    }

    await _toggleLike(
      type: LikeableType.comment,
      targetId: finalTargetId,
      targetOwnerId: commentOwnerId,
      targetPreview: commentPreview,
      notificationType: NotificationType.likeComment,
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  /// Quita like de un comentario
  Future<void> unlikeComment(
    String commentId, {
    String? contextTargetId,
    CommentableType? contextType,
    String? commentOwnerId,
  }) async {
    // Construir targetId compuesto para comentarios si se proporciona contexto
    String finalTargetId = commentId;
    if (contextType != null && contextTargetId != null) {
      final typeStr = contextType == CommentableType.post ? 'post' : 'ride';
      finalTargetId = '${typeStr}_${contextTargetId}_$commentId';
    }

    await _unlike(
      type: LikeableType.comment,
      targetId: finalTargetId,
      targetOwnerId: commentOwnerId,
    );
  }

  /// Observa si el usuario actual dio like a un comentario
  Stream<bool> watchUserLikedComment({
    required String commentId,
    String? contextTargetId,
    CommentableType? contextType,
  }) {
    // Construir targetId compuesto si se proporciona contexto
    String finalTargetId = commentId;
    if (contextType != null && contextTargetId != null) {
      final typeStr = contextType == CommentableType.post ? 'post' : 'ride';
      finalTargetId = '${typeStr}_${contextTargetId}_$commentId';
    }
    return _repository.watchUserLiked(
      LikeableType.comment,
      finalTargetId,
      userId,
    );
  }

  /// Observa el conteo de likes de un comentario
  Stream<int> watchCommentLikesCount({
    required String commentId,
    String? contextTargetId,
    CommentableType? contextType,
  }) {
    // Construir targetId compuesto si se proporciona contexto
    String finalTargetId = commentId;
    if (contextType != null && contextTargetId != null) {
      final typeStr = contextType == CommentableType.post ? 'post' : 'ride';
      finalTargetId = '${typeStr}_${contextTargetId}_$commentId';
    }
    return _repository.watchLikesCount(LikeableType.comment, finalTargetId);
  }

  /// Da like a una historia (expira en 24h)
  Future<void> likeStory({
    required String storyId,
    required String storyOwnerId,
  }) async {
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    await _toggleLike(
      type: LikeableType.story,
      targetId: storyId,
      targetOwnerId: storyOwnerId,
      expiresAt: expiresAt,
      notificationType: NotificationType.likeStory,
    );
  }

  /// Quita like de una historia
  Future<void> unlikeStory(String storyId, {String? storyOwnerId}) async {
    await _unlike(
      type: LikeableType.story,
      targetId: storyId,
      targetOwnerId: storyOwnerId,
    );
  }

  /// Toggle like (interno)
  Future<void> _toggleLike({
    required LikeableType type,
    required String targetId,
    required String targetOwnerId,
    String? targetPreview,
    DateTime? expiresAt,
    required NotificationType notificationType,
    Map<String, dynamic>? metadata,
  }) async {
    // Validaciones de entrada
    if (userId.isEmpty) {
      debugPrint('âŒ LikesProvider: userId vacÃ­o, abortando like');
      return;
    }
    if (targetId.isEmpty) {
      debugPrint('âŒ LikesProvider: targetId vacÃ­o, abortando like');
      return;
    }
    if (targetOwnerId.isEmpty) {
      debugPrint('âŒ LikesProvider: targetOwnerId vacÃ­o, abortando like');
      return;
    }
    // Cooldown: verificar si estÃ¡ en periodo de espera
    if (_isInCooldown(targetId)) {
      debugPrint(
        'â³ Like en cooldown para $targetId, espera ${_cooldownDuration.inSeconds}s',
      );
      return;
    }

    // Cargar datos del usuario si no estÃ¡n cargados
    await _loadUserData();

    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      await _repository.like(
        type: type,
        targetId: targetId,
        userId: userId,
        userName: _cachedUserName ?? 'Usuario',
        userPhoto: _cachedUserPhoto,
        expiresAt: expiresAt,
      );

      // Crear notificaciÃ³n con ID determinÃ­stico para evitar duplicados.
      // Si el usuario da like mÃ¡s de una vez (ej. doble-tap + botÃ³n),
      // el set() en el mismo path pisa la notificaciÃ³n anterior sin
      // incrementar el contador.
      if (targetOwnerId != userId) {
        final safeUserName = (_cachedUserName ?? '').trim().isNotEmpty
            ? _cachedUserName!
            : userId.split('_').last;

        // ID determinÃ­stico: permite sobrescribir sin duplicar
        final typeStr = type == LikeableType.post
            ? 'post'
            : type == LikeableType.comment
            ? 'comment'
            : 'story';
        final deterministicId = '${userId}_like_${typeStr}_$targetId';

        await _notificationsRepository.createNotification(
          userId: targetOwnerId,
          type: notificationType,
          fromUserId: userId,
          fromUserName: safeUserName,
          fromUserPhoto: _cachedUserPhoto,
          targetType: _getTargetType(type),
          targetId: targetId,
          targetPreview: targetPreview,
          metadata: metadata,
          notificationId: deterministicId,
        );
      }

      // Establecer cooldown despuÃ©s de completar exitosamente
      _setCooldown(targetId);

      _isProcessing = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _error = 'likes_error';
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Quita like (interno)
  Future<void> _unlike({
    required LikeableType type,
    required String targetId,
    String? targetOwnerId,
  }) async {
    // Validaciones de entrada
    if (userId.isEmpty) {
      debugPrint('âŒ LikesProvider: userId vacÃ­o, abortando unlike');
      return;
    }
    if (targetId.isEmpty) {
      debugPrint('âŒ LikesProvider: targetId vacÃ­o, abortando unlike');
      return;
    }
    // Cooldown: verificar si estÃ¡ en periodo de espera
    if (_isInCooldown(targetId)) {
      debugPrint(
        'â³ Unlike en cooldown para $targetId, espera ${_cooldownDuration.inSeconds}s',
      );
      return;
    }

    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      await _repository.unlike(type: type, targetId: targetId, userId: userId);

      // Eliminar la notificaciÃ³n de like usando el mismo ID determinÃ­stico
      if (targetOwnerId != null && targetOwnerId != userId) {
        final typeStr = type == LikeableType.post
            ? 'post'
            : type == LikeableType.comment
            ? 'comment'
            : 'story';
        final deterministicId = '${userId}_like_${typeStr}_$targetId';
        await _notificationsRepository.deleteNotification(
          targetOwnerId,
          deterministicId,
        );
      }

      // Establecer cooldown despuÃ©s de completar exitosamente
      _setCooldown(targetId);

      _isProcessing = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _error = 'likes_unlike_error';
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Obtiene el tipo de objetivo para notificaciÃ³n
  NotificationTargetType _getTargetType(LikeableType type) {
    switch (type) {
      case LikeableType.post:
        return NotificationTargetType.post;
      case LikeableType.comment:
        return NotificationTargetType.comment;
      case LikeableType.story:
        return NotificationTargetType.story;
    }
  }

  /// Stream de likes de un contenido
  Stream<List<LikeEntity>> watchLikes(LikeableType type, String targetId) {
    return _repository.watchLikes(type, targetId);
  }

  /// Stream del contador de likes
  Stream<int> watchLikesCount(LikeableType type, String targetId) {
    return _repository.watchLikesCount(type, targetId);
  }

  /// Stream para verificar si el usuario dio like
  Stream<bool> watchUserLiked(LikeableType type, String targetId) {
    return _repository.watchUserLiked(type, targetId, userId);
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

