import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/domain/repositories/user_profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          final score = _calculateSearchScore(user, query);

          // Solo incluir si tiene relevancia mínima (15%)
          // Umbral bajo permite búsquedas por 1-2 caracteres (como Instagram)
          if (score > 0.15) {
            resultsWithScore.add(MapEntry(user, score));
          }
        } catch (e) {
          print('Error procesando usuario ${doc.id}: $e');
          continue;
        }
      }

      // Ordenar por puntuación descendente (más relevante primero)
      resultsWithScore.sort((a, b) => b.value.compareTo(a.value));

      // Retornar solo los usuarios (sin la puntuación)
      return resultsWithScore.map((e) => e.key).toList();
    } catch (e) {
      print('❌ Error buscando usuarios: $e');
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
