import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/entities/notification_entity.dart';

/// Provider para gestionar comentarios
class CommentsProvider extends ChangeNotifier {
  final CommentsRepository _repository;
  final NotificationsRepository _notificationsRepository;
  final String userId;

  // Variables para caché de datos del usuario
  String? _cachedUserName;
  String? _cachedUserPhoto;
  bool _userDataLoaded = false;

  CommentsProvider({
    required CommentsRepository repository,
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
        // Fallback a Firebase Auth
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
      print(
        '✅ CommentsProvider: Datos de usuario cargados - userName: $_cachedUserName, photoUrl: $_cachedUserPhoto',
      );
    } catch (e) {
      print('⚠️ Error cargando datos de usuario en CommentsProvider: $e');
      _cachedUserName = 'Usuario';
      _cachedUserPhoto = null;
      _userDataLoaded = true;
    }
  }

  bool _isPosting = false;
  bool _isEditing = false;
  bool _isDeleting = false;
  String? _error;

  // Map para rastrear cooldown de comentarios (prevenir spam)
  final Map<String, DateTime> _commentCooldowns = {};

  // Duración del cooldown (5 segundos para comentarios - más largo para prevenir spam)
  static const Duration _commentCooldownDuration = Duration(seconds: 5);

  // Helper methods para cooldown
  bool _isInCommentCooldown(String targetId) {
    final lastAction = _commentCooldowns[targetId];
    if (lastAction == null) return false;
    return DateTime.now().difference(lastAction) < _commentCooldownDuration;
  }

  void _setCommentCooldown(String targetId) {
    _commentCooldowns[targetId] = DateTime.now();
  }

  bool get isPosting => _isPosting;
  bool get isEditing => _isEditing;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get isBusy => _isPosting || _isEditing || _isDeleting;

  /// Publica un comentario en un post
  Future<String?> commentOnPost({
    required String postId,
    required String postOwnerId,
    required String text,
    String? parentCommentId,
    String? parentCommentOwnerId,
  }) async {
    return _createComment(
      type: CommentableType.post,
      targetId: postId,
      targetOwnerId: postOwnerId,
      text: text,
      parentCommentId: parentCommentId,
      parentCommentOwnerId: parentCommentOwnerId,
    );
  }

  /// Publica un comentario en una rodada
  Future<String?> commentOnRide({
    required String rideId,
    required String rideOwnerId,
    required String text,
    String? parentCommentId,
    String? parentCommentOwnerId,
  }) async {
    return _createComment(
      type: CommentableType.ride,
      targetId: rideId,
      targetOwnerId: rideOwnerId,
      text: text,
      parentCommentId: parentCommentId,
      parentCommentOwnerId: parentCommentOwnerId,
    );
  }

  /// Crea un comentario (interno)
  Future<String?> _createComment({
    required CommentableType type,
    required String targetId,
    required String targetOwnerId,
    required String text,
    String? parentCommentId,
    String? parentCommentOwnerId,
  }) async {
    // Cooldown: prevenir spam de comentarios
    if (_isInCommentCooldown(targetId)) {
      debugPrint(
        '⏳ Comentario en cooldown para $targetId, espera ${_commentCooldownDuration.inSeconds}s',
      );
      _error =
          'Espera ${_commentCooldownDuration.inSeconds} segundos antes de comentar nuevamente';
      notifyListeners();
      return null;
    }

    if (_isPosting) return null;

    // Cargar datos del usuario si no están cargados
    await _loadUserData();

    // Validar longitud
    if (text.trim().isEmpty) {
      _error = 'El comentario no puede estar vacío';
      notifyListeners();
      return null;
    }

    if (text.length > 500) {
      _error = 'El comentario no puede tener más de 500 caracteres';
      notifyListeners();
      return null;
    }

    try {
      _isPosting = true;
      _error = null;
      notifyListeners();

      // Debug: Log antes de crear comentario
      debugPrint('📝 Intentando crear comentario...');
      debugPrint('   Tipo: $type');
      debugPrint('   TargetId: $targetId');
      debugPrint('   UserId: $userId');
      debugPrint('   UserName: $_cachedUserName');
      debugPrint('   UserPhoto: $_cachedUserPhoto');

      final commentId = await _repository.createComment(
        type: type,
        targetId: targetId,
        userId: userId,
        userName: _cachedUserName ?? 'Usuario',
        userPhoto: _cachedUserPhoto,
        text: text.trim(),
        parentCommentId: parentCommentId,
      );

      debugPrint('✅ Comentario creado: $commentId');

      // Crear notificación
      final isReply = parentCommentId != null;
      final recipientId = isReply ? parentCommentOwnerId! : targetOwnerId;

      // Solo notificar si no es el propio usuario
      if (recipientId != userId) {
        // ⚠️ Asegurar que userName no esté vacío (Firebase rules lo requieren)
        final safeUserName = (_cachedUserName ?? '').trim().isNotEmpty
            ? _cachedUserName!
            : userId.split('_').last; // Fallback: usar parte del userId

        await _notificationsRepository.createNotification(
          userId: recipientId,
          type: isReply
              ? NotificationType.replyComment
              : (type == CommentableType.post
                    ? NotificationType.commentPost
                    : NotificationType.commentRide),
          fromUserId: userId,
          fromUserName: safeUserName,
          fromUserPhoto: _cachedUserPhoto,
          targetType: type == CommentableType.post
              ? NotificationTargetType.post
              : NotificationTargetType.ride,
          targetId: targetId,
          targetPreview: text.length > 50
              ? '${text.substring(0, 50)}...'
              : text,
        );
      }

      // Detectar menciones y notificar
      await _notifyMentions(text, targetId, type);

      // Establecer cooldown después de éxito
      _setCommentCooldown(targetId);

      _isPosting = false;
      notifyListeners();

      return commentId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear comentario: $e');
      debugPrint('Stack trace: $stackTrace');

      // Detectar tipo de error específico
      if (e.toString().contains('MissingPluginException')) {
        _error =
            'Firebase DB no cargado. Reinicia la app (flutter run completo, NO hot reload)';
      } else if (e.toString().contains('permission')) {
        _error = 'Sin permisos. Verifica reglas de Firebase';
      } else if (e.toString().contains('network')) {
        _error = 'Sin conexión a internet';
      } else {
        _error = 'Error al publicar comentario: $e';
      }

      _isPosting = false;
      notifyListeners();
      return null;
    }
  }

  /// Edita un comentario
  Future<void> editComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
    required String newText,
  }) async {
    if (_isEditing) return;

    if (newText.trim().isEmpty) {
      _error = 'El comentario no puede estar vacío';
      notifyListeners();
      return;
    }

    if (newText.length > 500) {
      _error = 'El comentario no puede tener más de 500 caracteres';
      notifyListeners();
      return;
    }

    try {
      _isEditing = true;
      _error = null;
      notifyListeners();

      await _repository.updateComment(
        type: type,
        targetId: targetId,
        commentId: commentId,
        userId: userId,
        newText: newText.trim(),
      );

      _isEditing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al editar comentario: $e';
      _isEditing = false;
      notifyListeners();
    }
  }

  /// Elimina un comentario
  Future<void> deleteComment({
    required CommentableType type,
    required String targetId,
    required String commentId,
  }) async {
    if (_isDeleting) return;

    try {
      _isDeleting = true;
      _error = null;
      notifyListeners();

      await _repository.deleteComment(
        type: type,
        targetId: targetId,
        commentId: commentId,
        userId: userId,
      );

      _isDeleting = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar comentario: $e';
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Notifica a usuarios mencionados
  Future<void> _notifyMentions(
    String text,
    String targetId,
    CommentableType type,
  ) async {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(text);

    for (final match in matches) {
      final mentionedUsername = match.group(1);
      if (mentionedUsername == null || mentionedUsername == _cachedUserName)
        continue;

      // Aquí necesitarías obtener el userId del username mencionado
      // Por ahora lo dejamos como comentario para implementar después
      // final mentionedUserId = await _getUserIdByUsername(mentionedUsername);

      // if (mentionedUserId != null) {
      //   await _notificationsRepository.createNotification(
      //     userId: mentionedUserId,
      //     type: NotificationType.mention,
      //     fromUserId: userId,
      //     fromUserName: userName,
      //     fromUserPhoto: userPhoto,
      //     targetType: type == CommentableType.post
      //         ? NotificationTargetType.post
      //         : NotificationTargetType.ride,
      //     targetId: targetId,
      //     targetPreview: text.length > 50 ? '${text.substring(0, 50)}...' : text,
      //   );
      // }
    }
  }

  /// Stream de comentarios
  Stream<List<CommentEntity>> watchComments(
    CommentableType type,
    String targetId,
  ) {
    return _repository.watchComments(type, targetId);
  }

  /// Stream de respuestas
  Stream<List<CommentEntity>> watchReplies(
    CommentableType type,
    String targetId,
    String parentCommentId,
  ) {
    return _repository.watchReplies(type, targetId, parentCommentId);
  }

  /// Stream del contador de comentarios
  Stream<int> watchCommentsCount(CommentableType type, String targetId) {
    return _repository.watchCommentsCount(type, targetId);
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
