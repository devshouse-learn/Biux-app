import 'package:flutter/foundation.dart';
import '../../domain/entities/like_entity.dart';
import '../../domain/repositories/likes_repository.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/entities/notification_entity.dart';

/// Provider para gestionar likes
class LikesProvider extends ChangeNotifier {
  final LikesRepository _repository;
  final NotificationsRepository _notificationsRepository;
  final String userId;
  final String userName;
  final String? userPhoto;

  LikesProvider({
    required LikesRepository repository,
    required NotificationsRepository notificationsRepository,
    required this.userId,
    required this.userName,
    this.userPhoto,
  }) : _repository = repository,
       _notificationsRepository = notificationsRepository;

  bool _isProcessing = false;
  String? _error;

  bool get isProcessing => _isProcessing;
  String? get error => _error;

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
  Future<void> unlikePost(String postId) async {
    await _unlike(type: LikeableType.post, targetId: postId);
  }

  /// Da like a un comentario
  Future<void> likeComment({
    required String commentId,
    required String commentOwnerId,
    String? commentPreview,
  }) async {
    await _toggleLike(
      type: LikeableType.comment,
      targetId: commentId,
      targetOwnerId: commentOwnerId,
      targetPreview: commentPreview,
      notificationType: NotificationType.likeComment,
    );
  }

  /// Quita like de un comentario
  Future<void> unlikeComment(String commentId) async {
    await _unlike(type: LikeableType.comment, targetId: commentId);
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
  Future<void> unlikeStory(String storyId) async {
    await _unlike(type: LikeableType.story, targetId: storyId);
  }

  /// Toggle like (interno)
  Future<void> _toggleLike({
    required LikeableType type,
    required String targetId,
    required String targetOwnerId,
    String? targetPreview,
    DateTime? expiresAt,
    required NotificationType notificationType,
  }) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      await _repository.like(
        type: type,
        targetId: targetId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        expiresAt: expiresAt,
      );

      // Crear notificación solo si no es el propio usuario
      if (targetOwnerId != userId) {
        // ⚠️ Asegurar que userName no esté vacío (Firebase rules lo requieren)
        final safeUserName = userName.trim().isNotEmpty
            ? userName
            : userId.split('_').last; // Fallback: usar parte del userId

        await _notificationsRepository.createNotification(
          userId: targetOwnerId,
          type: notificationType,
          fromUserId: userId,
          fromUserName: safeUserName,
          fromUserPhoto: userPhoto,
          targetType: _getTargetType(type),
          targetId: targetId,
          targetPreview: targetPreview,
        );
      }

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al dar like: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Quita like (interno)
  Future<void> _unlike({
    required LikeableType type,
    required String targetId,
  }) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      await _repository.unlike(type: type, targetId: targetId, userId: userId);

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al quitar like: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Obtiene el tipo de objetivo para notificación
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
