import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/domain/repositories/user_profile_repository.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/data/repositories/notifications_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/foundation.dart";

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Calcular similitud entre strings usando Levenshtein
  double _calculateSimilarity(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final List<List<int>> distances = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) distances[i][0] = i;
    for (int j = 0; j <= s2.length; j++) distances[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        distances[i][j] = [
          distances[i - 1][j] + 1,
          distances[i][j - 1] + 1,
          distances[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distances[s1.length][s2.length] / maxLength);
  }

  // Calcula una puntuación de relevancia para cada usuario
  double _calculateSearchScore(BiuxUser user, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return 0.0;

    final fullName = user.fullName.toLowerCase();
    final userName = user.userName.toLowerCase();

    // 1. Coincidencia exacta (máxima prioridad: 1.0)
    if (fullName == q || userName == q) return 1.0;

    // 2. Comienza con (muy alta prioridad: 0.95)
    if (fullName.startsWith(q) || userName.startsWith(q)) return 0.95;

    // 3. Contiene (alta prioridad: 0.85)
    if (fullName.contains(q) || userName.contains(q)) return 0.85;

    // 4. Similitud fuzzy (prioridad media: 0.5 - 0.8)
    final nameSimi = _calculateSimilarity(fullName, q);
    final usernameSimi = _calculateSimilarity(userName, q);
    final maxSimi = nameSimi > usernameSimi ? nameSimi : usernameSimi;

    if (maxSimi > 0.5) {
      return 0.5 + (maxSimi * 0.3); // Rango: 0.5 - 0.8
    }

    return 0.0;
  }

  @override
  Future<List<BiuxUser>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // ignore: unused_local_variable
      final q = query.toLowerCase().trim();

      // Traer todos los usuarios disponibles (limitado para rendimiento)
      final allUsers = await _firestore.collection('users').limit(500).get();

      List<MapEntry<BiuxUser, double>> resultsWithScore = [];

      for (var doc in allUsers.docs) {
        if (doc.id == _currentUserId) continue;

        try {
          final userData = doc.data();
          userData['id'] = doc.id;
          final user = BiuxUser.fromJsonMap(userData);

          // Calcular puntuación de relevancia
          final score = _calculateSearchScore(user, q);

          // Solo incluir si tiene relevancia mínima (15%)
          // Umbral bajo permite búsquedas por 1-2 caracteres (como Instagram)
          if (score > 0.15) {
            resultsWithScore.add(MapEntry(user, score));
          }
        } catch (e) {
          debugPrint('Error procesando usuario ${doc.id}: $e');
          continue;
        }
      }

      // Ordenar por puntuación descendente (más relevante primero)
      resultsWithScore.sort((a, b) => b.value.compareTo(a.value));

      // Retornar solo los usuarios (sin la puntuación)
      return resultsWithScore.map((e) => e.key).toList();
    } catch (e) {
      debugPrint('❌ Error buscando usuarios: $e');
      return [];
    }
  }

  @override
  Future<BiuxUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final userData = doc.data()!;
        userData['id'] = doc.id;
        return BiuxUser.fromJsonMap(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> followUser(String userId) async {
    try {
      if (_currentUserId == null || _currentUserId == userId) return false;

      final batch = _firestore.batch();

      // Agregar a following del usuario actual
      final currentUserRef = _firestore.collection('users').doc(_currentUserId);
      batch.update(currentUserRef, {'following.$userId': true});

      // Agregar a followers del usuario objetivo
      final targetUserRef = _firestore.collection('users').doc(userId);
      batch.update(targetUserRef, {
        'followers.$_currentUserId': true,
        'followerS': FieldValue.increment(1),
      });

      await batch.commit();

      // Crear notificación de seguimiento en Realtime Database
      try {
        final currentUser = await _firestore
            .collection('users')
            .doc(_currentUserId)
            .get();
        final currentUserData = currentUser.data();

        final fromUserName =
            currentUserData?['fullName'] ??
            currentUserData?['userName'] ??
            'Usuario';
        final fromUserPhoto = currentUserData?['photo'] as String?;

        final notificationsRepo = NotificationsRepositoryImpl();
        await notificationsRepo.createNotification(
          userId: userId,
          type: NotificationType.follow,
          fromUserId: _currentUserId!,
          fromUserName: fromUserName,
          fromUserPhoto: fromUserPhoto,
        );
      } catch (notifError) {
        debugPrint('Error creando notificación de seguimiento: $notifError');
        // No fallar la operación si la notificación falla
      }

      return true;
    } catch (e) {
      debugPrint('Error siguiendo usuario: $e');
      return false;
    }
  }

  @override
  Future<bool> unfollowUser(String userId) async {
    try {
      if (_currentUserId == null || _currentUserId == userId) return false;

      final batch = _firestore.batch();

      // Remover de following del usuario actual
      final currentUserRef = _firestore.collection('users').doc(_currentUserId);
      batch.update(currentUserRef, {'following.$userId': FieldValue.delete()});

      // Remover de followers del usuario objetivo
      final targetUserRef = _firestore.collection('users').doc(userId);
      batch.update(targetUserRef, {
        'followers.$_currentUserId': FieldValue.delete(),
        'followerS': FieldValue.increment(-1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error dejando de seguir usuario: $e');
      return false;
    }
  }

  @override
  Future<List<BiuxUser>> getFollowers(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final followers = userData['followers'] as Map<String, dynamic>? ?? {};

      if (followers.isEmpty) return [];

      // Obtener datos de cada follower
      List<BiuxUser> followersList = [];
      for (String followerId in followers.keys) {
        final followerDoc = await _firestore
            .collection('users')
            .doc(followerId)
            .get();
        if (followerDoc.exists) {
          final followerData = followerDoc.data() as Map<String, dynamic>;
          followerData['id'] = followerDoc.id;
          followersList.add(BiuxUser.fromJsonMap(followerData));
        }
      }

      return followersList;
    } catch (e) {
      debugPrint('Error obteniendo followers: $e');
      return [];
    }
  }

  @override
  Future<List<BiuxUser>> getFollowing(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final following = userData['following'] as Map<String, dynamic>? ?? {};

      if (following.isEmpty) return [];

      // Obtener datos de cada usuario seguido
      List<BiuxUser> followingList = [];
      for (String followingId in following.keys) {
        final followingDoc = await _firestore
            .collection('users')
            .doc(followingId)
            .get();
        if (followingDoc.exists) {
          final followingData = followingDoc.data() as Map<String, dynamic>;
          followingData['id'] = followingDoc.id;
          followingList.add(BiuxUser.fromJsonMap(followingData));
        }
      }

      return followingList;
    } catch (e) {
      debugPrint('Error obteniendo following: $e');
      return [];
    }
  }

  @override
  Future<List<BiuxUser>> getUserExperiences(String userId) async {
    try {
      // Este método podría obtener las experiencias del usuario
      // Por ahora retornamos una lista vacía ya que las experiencias
      // se manejan en otro feature
      return [];
    } catch (e) {
      debugPrint('Error obteniendo experiencias de usuario: $e');
      return [];
    }
  }

  @override
  Future<bool> isFollowing(String userId) async {
    try {
      if (_currentUserId == null || _currentUserId == userId) return false;

      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        final following = userData['following'] as Map<String, dynamic>? ?? {};
        return following.containsKey(userId);
      }
      return false;
    } catch (e) {
      debugPrint('Error verificando si sigue usuario: $e');
      return false;
    }
  }

  // ========== FOLLOW REQUEST METHODS (for private accounts) ==========

  @override
  Future<bool> sendFollowRequest(String userId) async {
    try {
      if (_currentUserId == null || _currentUserId == userId) return false;

      debugPrint('📨 sendFollowRequest: de $_currentUserId a $userId');

      final currentUser = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      final currentUserData = currentUser.data();

      debugPrint(
        '📨 currentUserData: fullName=${currentUserData?['fullName']}, userName=${currentUserData?['userName']}, photo=${currentUserData?['photo']}',
      );

      // Create follow request document in the target user's subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('followRequests')
          .doc(_currentUserId)
          .set({
            'fromUserId': _currentUserId,
            'fromUserName':
                currentUserData?['fullName'] ??
                currentUserData?['userName'] ??
                'Usuario',
            'fromUserPhoto': currentUserData?['photo'] ?? '',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ Follow request creado en Firestore');

      // Create notification in Realtime Database (where the app reads from)
      try {
        final fromUserName =
            currentUserData?['fullName'] ??
            currentUserData?['userName'] ??
            'Usuario';
        final fromUserPhoto = currentUserData?['photo'] as String?;

        debugPrint(
          '📨 Creando notificación en RTDB para userId: $userId, fromUserName: $fromUserName',
        );

        final notificationsRepo = NotificationsRepositoryImpl();
        await notificationsRepo.createNotification(
          userId: userId,
          type: NotificationType.followRequest,
          fromUserId: _currentUserId!,
          fromUserName: fromUserName,
          fromUserPhoto: fromUserPhoto,
          notificationId: 'follow_request_${_currentUserId}',
        );
        debugPrint(
          '✅ Notificación de follow_request creada en RTDB para $userId',
        );
      } catch (notifError) {
        debugPrint('❌ Error creando notificación de solicitud: $notifError');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error enviando solicitud de seguimiento: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelFollowRequest(String userId) async {
    try {
      if (_currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('followRequests')
          .doc(_currentUserId)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error cancelando solicitud de seguimiento: $e');
      return false;
    }
  }

  @override
  Future<bool> acceptFollowRequest(String requesterId) async {
    try {
      if (_currentUserId == null) return false;

      final batch = _firestore.batch();

      // Add to following/followers (same as followUser)
      final requesterRef = _firestore.collection('users').doc(requesterId);
      batch.update(requesterRef, {'following.$_currentUserId': true});

      final currentUserRef = _firestore.collection('users').doc(_currentUserId);
      batch.update(currentUserRef, {
        'followers.$requesterId': true,
        'followerS': FieldValue.increment(1),
      });

      await batch.commit();

      // Delete the follow request
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('followRequests')
          .doc(requesterId)
          .delete();

      // Create notification for the requester in Realtime Database
      try {
        final currentUser = await _firestore
            .collection('users')
            .doc(_currentUserId)
            .get();
        final currentUserData = currentUser.data();

        final fromUserName =
            currentUserData?['fullName'] ??
            currentUserData?['userName'] ??
            'Usuario';
        final fromUserPhoto = currentUserData?['photo'] as String?;

        final notificationsRepo = NotificationsRepositoryImpl();
        await notificationsRepo.createNotification(
          userId: requesterId,
          type: NotificationType.follow,
          fromUserId: _currentUserId!,
          fromUserName: fromUserName,
          fromUserPhoto: fromUserPhoto,
        );
      } catch (notifError) {
        debugPrint('Error creando notificación de aceptación: $notifError');
      }

      // Delete the follow_request notification from the current user
      try {
        final notificationsRepo = NotificationsRepositoryImpl();
        await notificationsRepo.deleteNotification(
          _currentUserId!,
          'follow_request_$requesterId',
        );
      } catch (e) {
        debugPrint('Error eliminando notificación de solicitud: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error aceptando solicitud de seguimiento: $e');
      return false;
    }
  }

  @override
  Future<bool> rejectFollowRequest(String requesterId) async {
    try {
      if (_currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('followRequests')
          .doc(requesterId)
          .delete();

      // Delete the follow_request notification
      try {
        final notificationsRepo = NotificationsRepositoryImpl();
        await notificationsRepo.deleteNotification(
          _currentUserId!,
          'follow_request_$requesterId',
        );
      } catch (e) {
        debugPrint('Error eliminando notificación de solicitud: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error rechazando solicitud de seguimiento: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPendingFollowRequest(String userId) async {
    try {
      if (_currentUserId == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followRequests')
          .doc(_currentUserId)
          .get();

      return doc.exists && (doc.data()?['status'] == 'pending');
    } catch (e) {
      debugPrint('Error verificando solicitud pendiente: $e');
      return false;
    }
  }

  @override
  Future<List<BiuxUser>> getFollowRequests() async {
    try {
      if (_currentUserId == null) return [];

      final requestsSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('followRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      List<BiuxUser> requesters = [];
      for (var doc in requestsSnapshot.docs) {
        final requesterDoc = await _firestore
            .collection('users')
            .doc(doc.id)
            .get();
        if (requesterDoc.exists) {
          final data = requesterDoc.data() as Map<String, dynamic>;
          data['id'] = requesterDoc.id;
          requesters.add(BiuxUser.fromJsonMap(data));
        }
      }

      return requesters;
    } catch (e) {
      debugPrint('Error obteniendo solicitudes de seguimiento: $e');
      return [];
    }
  }

  @override
  Future<bool> updateProfileVisibility(String visibility) async {
    try {
      if (_currentUserId == null) return false;

      await _firestore.collection('users').doc(_currentUserId).update({
        'profileVisibility': visibility,
      });

      return true;
    } catch (e) {
      debugPrint('Error actualizando visibilidad del perfil: $e');
      return false;
    }
  }
}
