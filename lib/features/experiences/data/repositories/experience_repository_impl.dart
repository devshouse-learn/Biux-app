import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/models/experience_model.dart';
import 'package:biux/shared/services/optimized_storage_service.dart';

/// Implementación del repository para experiencias usando Firebase
class ExperienceRepositoryImpl implements ExperienceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExperienceRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('experiences')
              .where('user.id', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                ExperienceModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo experiencias del usuario: $e');
    }
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    try {
      final snapshot =
          await _firestore
              .collection('experiences')
              .where('rideId', isEqualTo: rideId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                ExperienceModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo experiencias de la rodada: $e');
    }
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    try {
      // Obtener lista de usuarios que sigue
      final followingSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('following')
              .get();

      final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();

      if (followingIds.isEmpty) {
        return [];
      }

      // Obtener experiencias de usuarios seguidos
      final snapshot =
          await _firestore
              .collection('experiences')
              .where('user.id', whereIn: followingIds)
              .orderBy('createdAt', descending: true)
              .limit(50)
              .get();

      return snapshot.docs
          .map(
            (doc) =>
                ExperienceModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo experiencias de seguidores: $e');
    }
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear ID único para la experiencia
      final experienceId = _firestore.collection('experiences').doc().id;

      // Subir archivos multimedia
      final mediaList = <ExperienceMediaModel>[];

      for (int i = 0; i < request.mediaFiles.length; i++) {
        final mediaFile = request.mediaFiles[i];

        // Generar ID único para el archivo
        final mediaId = '${experienceId}_media_$i';

        // Subir archivo y obtener URL
        final url = await uploadMedia(
          filePath: mediaFile.filePath,
          mediaType: mediaFile.mediaType,
          experienceId: experienceId,
        );

        // Generar thumbnail para videos
        String? thumbnailUrl;
        if (mediaFile.mediaType == MediaType.video) {
          // TODO: Implementar generación de thumbnail
          thumbnailUrl = url; // Por ahora usar la misma URL
        }

        mediaList.add(
          ExperienceMediaModel(
            id: mediaId,
            url: url,
            mediaType: mediaFile.mediaType,
            duration: mediaFile.duration,
            aspectRatio: mediaFile.aspectRatio,
            thumbnailUrl: thumbnailUrl,
          ),
        );
      }

      // Obtener datos del usuario actual
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final userModel = UserModel(
        id: user.uid,
        fullName: userData['fullName'] ?? user.displayName ?? '',
        userName: userData['userName'] ?? '',
        email: user.email ?? '',
        photo: userData['photo'] ?? user.photoURL ?? '',
      );

      // Crear modelo de experiencia
      final experienceModel = ExperienceModel(
        id: experienceId,
        description: request.description,
        tags: request.tags,
        user: userModel,
        createdAt: DateTime.now(),
        media: mediaList,
        type: request.type,
        rideId: request.rideId,
        views: 0,
        reactions: [],
      );

      // Guardar en Firestore
      await _firestore
          .collection('experiences')
          .doc(experienceId)
          .set(experienceModel.toJson());

      return experienceModel.toEntity();
    } catch (e) {
      throw Exception('Error creando experiencia: $e');
    }
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que la experiencia pertenece al usuario
      final doc =
          await _firestore.collection('experiences').doc(experienceId).get();
      if (!doc.exists) {
        throw Exception('Experiencia no encontrada');
      }

      final data = doc.data()!;
      if (data['user']['id'] != user.uid) {
        throw Exception('No tienes permisos para eliminar esta experiencia');
      }

      // Eliminar archivos multimedia del storage
      final media = data['media'] as List;
      for (final mediaItem in media) {
        try {
          await OptimizedStorageService.deleteImage(mediaItem['url']);
        } catch (e) {
          // Continuar aunque falle eliminación de archivo
          print('Error eliminando archivo: $e');
        }
      }

      // Eliminar documento de Firestore
      await _firestore.collection('experiences').doc(experienceId).delete();
    } catch (e) {
      throw Exception('Error eliminando experiencia: $e');
    }
  }

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final reactionData = {
        'id': '${experienceId}_${user.uid}',
        'user': {
          'id': user.uid,
          'fullName': user.displayName ?? '',
          'userName': '',
          'email': user.email ?? '',
          'photo': user.photoURL ?? '',
        },
        'type': reaction.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('experiences').doc(experienceId).update({
        'reactions': FieldValue.arrayUnion([reactionData]),
      });
    } catch (e) {
      throw Exception('Error agregando reacción: $e');
    }
  }

  @override
  Future<void> removeReaction(String experienceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener la experiencia para encontrar la reacción del usuario
      final doc =
          await _firestore.collection('experiences').doc(experienceId).get();
      if (!doc.exists) {
        throw Exception('Experiencia no encontrada');
      }

      final data = doc.data()!;
      final reactions = List.from(data['reactions'] ?? []);

      // Remover la reacción del usuario actual
      reactions.removeWhere((reaction) => reaction['user']['id'] == user.uid);

      await _firestore.collection('experiences').doc(experienceId).update({
        'reactions': reactions,
      });
    } catch (e) {
      throw Exception('Error removiendo reacción: $e');
    }
  }

  @override
  Future<void> markAsViewed(String experienceId) async {
    try {
      await _firestore.collection('experiences').doc(experienceId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error marcando como vista: $e');
    }
  }

  @override
  Future<String> uploadMedia({
    required String filePath,
    required MediaType mediaType,
    required String experienceId,
    Function(double)? onProgress,
  }) async {
    try {
      final result = await OptimizedStorageService.uploadExperienceMedia(
        userId: experienceId, // Asumimos que tenemos el userId disponible
        mediaFile: File(filePath),
        mediaType: mediaType.name,
        experienceType: 'general', // Podríamos hacer esto configurable
        experienceId: experienceId,
        onProgress: onProgress != null ? () => onProgress(0.0) : null,
      );

      return result?['url'] ?? result?['optimizedUrl'] ?? '';
    } catch (e) {
      throw Exception('Error subiendo archivo multimedia: $e');
    }
  }
}
