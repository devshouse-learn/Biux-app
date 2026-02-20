import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/domain/repositories/user_profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<List<BiuxUser>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final q = query.toLowerCase().trim();

      // Traer todos los usuarios disponibles y filtrar en memoria
      // Esto garantiza resultados con búsqueda case-insensitive
      final allUsers = await _firestore.collection('users').limit(1000).get();

      List<BiuxUser> results = [];

      for (var doc in allUsers.docs) {
        if (doc.id == _currentUserId) continue;

        final userData = doc.data();
        final fullName = userData['fullName']?.toString().toLowerCase() ?? '';
        final userName = userData['userName']?.toString().toLowerCase() ?? '';
        final description =
            userData['description']?.toString().toLowerCase() ?? '';

        // Buscar en cualquier campo
        if (fullName.contains(q) ||
            userName.contains(q) ||
            description.contains(q)) {
          userData['id'] = doc.id;
          results.add(BiuxUser.fromJsonMap(userData));
        }
      }

      // Ordenar: prioridad a coincidencias exactas y al inicio
      results.sort((a, b) {
        final aFullLower = a.fullName.toLowerCase();
        final aUserLower = a.userName.toLowerCase();
        final bFullLower = b.fullName.toLowerCase();
        final bUserLower = b.userName.toLowerCase();

        // Exact match tiene máxima prioridad
        if (aFullLower == q || aUserLower == q) return -1;
        if (bFullLower == q || bUserLower == q) return 1;

        // Starts with tiene prioridad media
        if (aFullLower.startsWith(q) || aUserLower.startsWith(q)) return -1;
        if (bFullLower.startsWith(q) || bUserLower.startsWith(q)) return 1;

        return 0;
      });

      return results;
    } catch (e) {
      print('Error buscando usuarios: $e');
      return [];
    }
  }

  @override
  Future<BiuxUser?> getUserProfile(String userId) async {
    try {
      print('🔍 REPOSITORY: Consultando usuario con ID: "$userId"');
      print('🔍 REPOSITORY: Colección: users, Documento: $userId');

      final doc = await _firestore.collection('users').doc(userId).get();

      print('🔍 REPOSITORY: Documento existe: ${doc.exists}');

      if (doc.exists) {
        final userData = doc.data()!;
        userData['id'] = doc.id;

        print('🔍 REPOSITORY: Datos encontrados:');
        print('  - ID: "${userData['id']}"');
        print('  - FullName: "${userData['fullName'] ?? 'VACÍO'}"');
        print('  - Name: "${userData['name'] ?? 'VACÍO'}"');
        print('  - UserName: "${userData['userName'] ?? 'VACÍO'}"');
        print('  - Email: "${userData['email'] ?? 'VACÍO'}"');
        print('  - Photo: "${userData['photo'] ?? 'VACÍO'}"');
        print('  - PhotoUrl: "${userData['photoUrl'] ?? 'VACÍO'}"');
        print('  - Todos los campos disponibles: ${userData.keys.toList()}');

        final user = BiuxUser.fromJsonMap(userData);
        print('🔍 REPOSITORY: Usuario creado exitosamente');
        return user;
      } else {
        print('❌ REPOSITORY: Documento no existe para ID: "$userId"');
      }
      return null;
    } catch (e) {
      print('❌ REPOSITORY: Error obteniendo perfil de usuario: $e');
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

      // Crear notificación de seguimiento
      try {
        final currentUser = await _firestore
            .collection('users')
            .doc(_currentUserId)
            .get();
        final currentUserData = currentUser.data();

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .add({
              'type': 'follow',
              'fromUserId': _currentUserId,
              'fromUserName':
                  currentUserData?['fullName'] ??
                  currentUserData?['userName'] ??
                  'Usuario',
              'fromUserPhoto': currentUserData?['photo'],
              'message': 'ha comenzado a seguirte',
              'isRead': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
      } catch (notifError) {
        print('Error creando notificación de seguimiento: $notifError');
        // No fallar la operación si la notificación falla
      }

      return true;
    } catch (e) {
      print('Error siguiendo usuario: $e');
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
      print('Error dejando de seguir usuario: $e');
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
      print('Error obteniendo followers: $e');
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
      print('Error obteniendo following: $e');
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
      print('Error obteniendo experiencias de usuario: $e');
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
      print('Error verificando si sigue usuario: $e');
      return false;
    }
  }
}
