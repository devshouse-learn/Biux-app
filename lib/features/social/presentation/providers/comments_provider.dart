import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Provider para gestionar comentarios
class CommentsProvider extends ChangeNotifier {
  final CommentsRepository _repository;
  final String userId;

  // Variables para caché de datos del usuario
  String? _cachedUserName;
  String? _cachedUserPhoto;
  bool _userDataLoaded = false;

  CommentsProvider({
    required CommentsRepository repository,
    required NotificationsRepository notificationsRepository,
    required this.userId,
  }) : _repository = repository;

  /// Obtiene los datos del usuario desde Firestore (se ejecuta una sola vez)
  Future<void> _loadUserData() async {
    if (_userDataLoaded) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _cachedUserName = null;
        _cachedUserPhoto = null;
        _userDataLoaded = true;
        return;
      }

      // Obtener datos desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      print('🔍 Buscando usuario en Firestore: $userId');
      print('🔍 Documento existe: ${userDoc.exists}');

      final userData = userDoc.data();

      if (userData != null) {
        print('🔍 Datos del usuario: $userData');
      }

      if (userData != null && userData.isNotEmpty) {
        String? name = userData['name'];
        String? username = userData['username'];
        String? fullName = userData['fullName'];

        // Solo usar nombres reales, NO usar fallbacks
        _cachedUserName = null;

        if (name != null && name.trim().isNotEmpty) {
          _cachedUserName = name.trim();
        } else if (username != null && username.trim().isNotEmpty) {
          _cachedUserName = username.trim();
        } else if (fullName != null && fullName.trim().isNotEmpty) {
          _cachedUserName = fullName.trim();
        }

        _cachedUserPhoto = userData['photoUrl'] ?? userData['photo'];
      } else {
        // Si no hay datos en Firestore, el usuario no ha completado su perfil
        _cachedUserName = null;
        _cachedUserPhoto = null;
      }

      _userDataLoaded = true;
      print('✅ CommentsProvider: Datos de usuario cargados');
      print('   👤 UserId: $userId');
      print('   📝 UserName encontrado: $_cachedUserName');
      print('   📸 UserPhoto: $_cachedUserPhoto');
      print('   ✔️ Perfil completo: $hasCompletedProfile');
    } catch (e) {
      print('⚠️ Error cargando datos de usuario en CommentsProvider: $e');
      _cachedUserName = null;
      _cachedUserPhoto = null;
      _userDataLoaded = true;
    }
  }

  /// Verifica si el usuario ha completado su perfil (tiene nombre)
  bool get hasCompletedProfile =>
      _cachedUserName != null && _cachedUserName!.trim().isNotEmpty;

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

      // IMPORTANTE: Forzar recarga de datos para asegurar que están actualizados
      _userDataLoaded = false;

      // Cargar datos del usuario si no están cargados
      await _loadUserData();

      // DEBUG: Mostrar estado de validación
      debugPrint('🔍 Validando perfil del usuario...');
      debugPrint('   _cachedUserName: $_cachedUserName');
      debugPrint('   hasCompletedProfile: $hasCompletedProfile');

      // Verificar que el usuario haya completado su perfil
      if (!hasCompletedProfile) {
        debugPrint('❌ Usuario sin perfil completo, redirigiendo...');
        _error = 'complete_profile'; // Error especial para detectar en UI
        _isPosting = false;
        notifyListeners();
        return null;
      }

      // Verificar autenticación de Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Usuario no autenticado en Firebase Auth');
        _error = 'Debes iniciar sesión para comentar';
        _isPosting = false;
        notifyListeners();
        return null;
      }

      debugPrint('🔐 Firebase Auth UID: ${currentUser.uid}');
      debugPrint('🔐 Provider userId: $userId');

      if (currentUser.uid != userId) {
        debugPrint(
          '⚠️ WARNING: Firebase Auth UID no coincide con Provider userId',
        );
        debugPrint(
          '   Usando Firebase Auth UID para cumplir reglas de seguridad',
        );
      }

      // IMPORTANTE: Usar currentUser.uid para cumplir con las reglas de seguridad
      // Las reglas requieren que userId === auth.uid
      final userIdForComment = currentUser.uid;

      // Debug: Log antes de crear comentario
      debugPrint('📝 Intentando crear comentario...');
      debugPrint('   Tipo: $type');
      debugPrint('   TargetId: $targetId');
      debugPrint('   UserId para comentario: $userIdForComment');
      debugPrint('   UserName: $_cachedUserName');
      debugPrint('   UserPhoto: $_cachedUserPhoto');

      final commentId = await _repository.createComment(
        type: type,
        targetId: targetId,
        userId: userIdForComment,
        userName: _cachedUserName!,
        userPhoto: _cachedUserPhoto,
        text: text.trim(),
        parentCommentId: parentCommentId,
      );

      debugPrint('✅ Comentario creado: $commentId');

      // ⚠️ Las notificaciones son creadas automáticamente por Cloud Functions
      // Ver: biux-cloud/functions/comment-notifications.js
      // Triggers: onCommentPostCreated, onCommentRideCreated

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

      debugPrint('🗑️ Intentando eliminar comentario:');
      debugPrint('   Tipo: $type');
      debugPrint('   TargetId: $targetId');
      debugPrint('   CommentId: $commentId');
      debugPrint('   UserId actual: $userId');

      await _repository.deleteComment(
        type: type,
        targetId: targetId,
        commentId: commentId,
        userId: userId,
      );

      debugPrint('✅ Comentario eliminado correctamente');
      _isDeleting = false;
      notifyListeners();
    } catch (e, st) {
      final errorMsg = e.toString();
      debugPrint('❌ Error al eliminar comentario: $errorMsg');
      debugPrint('Stack trace: $st');

      if (errorMsg.contains('permiso')) {
        _error = 'No tienes permiso para eliminar este comentario';
      } else if (errorMsg.contains('No existe')) {
        _error = 'El comentario no existe';
      } else {
        _error = 'Error al eliminar: $errorMsg';
      }

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
