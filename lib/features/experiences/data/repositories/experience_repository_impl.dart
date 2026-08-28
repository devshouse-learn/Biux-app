import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/models/experience_model.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import "package:flutter/foundation.dart";
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/exceptions/backend_exceptions.dart';

/// Implementación del repository para experiencias usando Firebase
class ExperienceRepositoryImpl implements ExperienceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExperienceRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Obtener modelo de usuario para experiencias desde Firestore
  Future<UserModel> _getUserModel(User firebaseUser) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      final userData = userDoc.data() ?? {};

      // Mapear desde el formato de Firestore al UserModel de experiencias
      return UserModel(
        id: firebaseUser.uid,
        fullName:
            _getStringValue(userData['name']) ??
            _getStringValue(userData['fullName']) ??
            firebaseUser.displayName ??
            'Usuario',
        userName:
            _getStringValue(userData['username']) ??
            _getStringValue(userData['userName']) ??
            _generateUsername(firebaseUser.uid),
        email: firebaseUser.email ?? 'usuario@biux.com',
        photo:
            _getStringValue(userData['photoUrl']) ??
            _getStringValue(userData['photo']) ??
            firebaseUser.photoURL ??
            '',
      );
    } on FirebaseException catch (e) {
      // Si hay error obteniendo desde Firestore, usar datos básicos de Firebase Auth
      return UserModel(
        id: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? 'Usuario',
        userName: _generateUsername(firebaseUser.uid),
        email: firebaseUser.email ?? 'usuario@biux.com',
        photo: firebaseUser.photoURL ?? '',
      );
    }
  }

  /// Generar nombre de usuario desde UID
  String _generateUsername(String uid) {
    return 'user_${uid.substring(0, 8)}';
  }

  /// Obtener valor string de forma segura desde Map
  String? _getStringValue(dynamic value) {
    if (value == null) return null;
    return value.toString().isEmpty ? null : value.toString();
  }

  @override
  Future<List<ExperienceEntity>> getUserExperiences(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('user.id', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExperienceModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'ExperienceRepository',
        'getUserExperiences',
        'No se pudieron obtener las experiencias: ${e.code}',
      );
    }
  }

  /// Obtener experiencias por una lista de IDs
  Future<List<ExperienceEntity>> getExperiencesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      // Firestore 'whereIn' supports max 30 items per query
      final results = <ExperienceEntity>[];
      for (var i = 0; i < ids.length; i += 30) {
        final batch = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
        final snapshot = await _firestore
            .collection('experiences')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        results.addAll(
          snapshot.docs.map(
            (doc) => ExperienceModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          ),
        );
      }
      return results;
    } on FirebaseException catch (e) {
      return [];
    }
  }

  @override
  Future<ExperienceEntity?> getExperienceById(String experienceId) async {
    try {
      final doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();

      if (!doc.exists) {
        AppLogger.warning(
          'REPO: Experiencia no encontrada: $experienceId',
          tag: 'ExperienceRepository',
        );
        return null;
      }

      return ExperienceModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }).toEntity();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'REPO: Error obteniendo experiencia por ID',
        error: e,
        tag: 'ExperienceRepository',
      );
      throw ResourceNotFoundException('Experiencia');
    }
  }

  @override
  Future<List<ExperienceEntity>> getRideExperiences(String rideId) async {
    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('rideId', isEqualTo: rideId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExperienceModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'ExperienceRepository',
        'getRideExperiences',
        'No se pudieron obtener experiencias de la rodada: ${e.code}',
      );
    }
  }

  @override
  Future<List<ExperienceEntity>> getFollowingExperiences(String userId) async {
    try {
      AppLogger.info(
        'Obteniendo experiencias de usuarios seguidos',
        tag: 'ExperienceRepository',
      );

      final followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      List<String> followingIds = followingSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      AppLogger.debug(
        'Usuarios seguidos encontrados: ${followingIds.length}',
        tag: 'ExperienceRepository',
      );

      if (followingIds.isEmpty) {
        return [];
      }

      final List<ExperienceEntity> allExperiences = [];
      const int chunkSize = 10;

      for (int i = 0; i < followingIds.length; i += chunkSize) {
        final chunk = followingIds.sublist(
          i,
          (i + chunkSize).clamp(0, followingIds.length),
        );

        final snapshot = await _firestore
            .collection('experiences')
            .where('user.id', whereIn: chunk)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        allExperiences.addAll(
          snapshot.docs
              .map(
                (doc) => ExperienceModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }).toEntity(),
              )
              .toList(),
        );
      }

      // Ordenar por fecha descendente (más recientes primero)
      allExperiences.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.info(
        'Experiencias encontradas: ${allExperiences.length}',
        tag: 'ExperienceRepository',
      );

      return allExperiences;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error obteniendo experiencias de seguidos: $e',
        tag: 'ExperienceRepository',
        error: e,
      );
      return [];
    }
  }

  /// Obtiene posts de descubrimiento (todos los posts)
  Future<List<ExperienceEntity>> getDiscoveryExperiences() async {
    try {
      AppLogger.info(
        'Cargando posts de descubrimiento...',
        tag: 'ExperienceRepository',
      );

      final snapshot = await _firestore
          .collection('experiences')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final experiences = snapshot.docs
          .map(
            (doc) => ExperienceModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          )
          .toList();

      AppLogger.info(
        '✅ Posts de descubrimiento cargados: ${experiences.length}',
        tag: 'ExperienceRepository',
      );

      return experiences;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error cargando descubrimiento: $e',
        tag: 'ExperienceRepository',
        error: e,
      );
      return [];
    }
  }

  @override
  Stream<DateTime?> watchLatestExperienceTimestamp() {
    return _firestore
        .collection('experiences')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final data = snapshot.docs.first.data();
          final createdAt = data['createdAt'];
          if (createdAt is Timestamp) return createdAt.toDate();
          return null;
        });
  }

  @override
  Future<ExperienceEntity> createExperience(
    CreateExperienceRequest request,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw NotAuthenticatedException();
      }

      // Crear ID Ãºnico para la experiencia
      final experienceId = _firestore.collection('experiences').doc().id;

      // Subir archivos multimedia
      final mediaList = <ExperienceMediaModel>[];

      for (int i = 0; i < request.mediaFiles.length; i++) {
        final mediaFile = request.mediaFiles[i];

        // Generar ID Ãºnico para el archivo
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
          // IMPLEMENTADO (STUB): Implementar generación de thumbnail
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
            description: mediaFile.description,
          ),
        );
      }

      // Obtener datos del usuario actual desde el UserProvider o Firestore
      final userModel = await _getUserModel(user);

      // Crear modelo de experiencia
      final experienceModel = ExperienceModel(
        id: experienceId,
        description: request.description,
        tags: request.tags,
        user: userModel,
        createdAt: DateTime.now(),
        media: mediaList,
        type: request.type,
        format: request.format,
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
    } on FirebaseException catch (e) {
      throw Exception('Error creando experiencia: $e');
    }
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw NotAuthenticatedException();
      }

      // Intentar obtener el documento directamente por ID
      var doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();

      // Si no existe por doc ID, buscar por el campo 'id' interno
      if (!doc.exists) {
        final query = await _firestore
            .collection('experiences')
            .where('id', isEqualTo: experienceId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }

      if (!doc.exists) {
        throw ResourceNotFoundException('Experiencia');
      }

      final data = doc.data()!;
      final actualDocId = doc.id;

      if (data['user']['id'] != user.uid) {
        throw UnauthorizedException('eliminar esta experiencia');
      }

      // Eliminar documento de Firestore primero (para que desaparezca de la UI rápido)
      await _firestore.collection('experiences').doc(actualDocId).delete();

      // Eliminar archivos multimedia del storage en paralelo (en segundo plano)
      final media = data['media'] as List;
      final deleteFutures = media.map((mediaItem) {
        try {
          final url = mediaItem['url'] as String;
          final ref = FirebaseStorage.instance.refFromURL(url);
          return ref.delete().catchError((_) {});
        } catch (e) {
          return Future.value();
        }
      });
      await Future.wait(deleteFutures);
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'ExperienceRepository',
        'deleteExperience',
        'No se pudo eliminar la experiencia: ${e.code}',
      );
    }
  }

  @override
  Future<bool> removeMediaFromExperience(
    String experienceId,
    int mediaIndex,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw NotAuthenticatedException();

      final doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();
      if (!doc.exists) throw ResourceNotFoundException('Experiencia');

      final data = doc.data()!;
      if (data['user']['id'] != user.uid) {
        throw Exception('No tienes permisos para editar esta experiencia');
      }

      final mediaList = List<Map<String, dynamic>>.from(
        (data['media'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );

      if (mediaIndex < 0 || mediaIndex >= mediaList.length) {
        throw Exception('Ãndice de media inválido');
      }

      // Si es el Ãºltimo media, eliminar toda la experiencia
      if (mediaList.length == 1) {
        await deleteExperience(experienceId);
        return true; // true = experiencia eliminada completamente
      }

      // Eliminar el archivo del Storage
      final mediaToRemove = mediaList[mediaIndex];
      try {
        final ref = FirebaseStorage.instance.refFromURL(
          mediaToRemove['url'] as String,
        );
        await ref.delete();
      } on FirebaseException catch (e) {
        debugPrint('Error: ' + e.toString());
      }

      // Remover del array y actualizar Firestore
      mediaList.removeAt(mediaIndex);
      await _firestore.collection('experiences').doc(experienceId).update({
        'media': mediaList,
      });

      return false; // false = solo se eliminó una foto
    } on FirebaseException catch (e) {
      throw Exception('Error eliminando media: $e');
    }
  }

  @override
  Future<void> updateExperience(
    String experienceId, {
    required String description,
    bool isEdited = true,
    List<CreateMediaRequest>? newMediaFiles,
    List<String>? existingMediaUrls,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que la experiencia pertenece al usuario
      final doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();
      if (!doc.exists) {
        throw Exception('Experiencia no encontrada');
      }

      final data = doc.data()!;
      if (data['user']['id'] != user.uid) {
        throw Exception('No tienes permisos para editar esta experiencia');
      }

      // Preparar campos a actualizar
      final Map<String, dynamic> updateData = {
        'description': description,
        'isEdited': isEdited,
      };

      // Si hay cambios de media
      final bool hasNewMedia =
          newMediaFiles != null && newMediaFiles.isNotEmpty;
      final bool hasExistingUrls = existingMediaUrls != null;

      if (hasNewMedia || hasExistingUrls) {
        final mediaList = <Map<String, dynamic>>[];

        // Mantener media existente que no fue eliminada
        if (existingMediaUrls != null) {
          final oldMedia = data['media'] as List;
          for (final oldItem in oldMedia) {
            final oldUrl = oldItem['url'] as String;
            if (existingMediaUrls.contains(oldUrl)) {
              mediaList.add(Map<String, dynamic>.from(oldItem as Map));
            } else {
              // Eliminar del storage el archivo que ya no se usa
              try {
                final ref = FirebaseStorage.instance.refFromURL(oldUrl);
                await ref.delete();
              } on FirebaseException catch (e) {
                debugPrint('Error eliminando archivo antiguo: $e');
              }
            }
          }
        }

        // Subir nuevos archivos
        if (hasNewMedia) {
          for (int i = 0; i < newMediaFiles.length; i++) {
            final mediaFile = newMediaFiles[i];
            final mediaId =
                '${experienceId}_media_edit_${DateTime.now().millisecondsSinceEpoch}_$i';

            final url = await uploadMedia(
              filePath: mediaFile.filePath,
              mediaType: mediaFile.mediaType,
              experienceId: experienceId,
            );

            String? thumbnailUrl;
            if (mediaFile.mediaType == MediaType.video) {
              thumbnailUrl = url;
            }

            mediaList.add({
              'id': mediaId,
              'url': url,
              'mediaType': mediaFile.mediaType.name,
              'duration': mediaFile.duration,
              'aspectRatio': mediaFile.aspectRatio,
              'thumbnailUrl': thumbnailUrl,
              'description': mediaFile.description,
            });
          }
        }

        updateData['media'] = mediaList;
      }

      // Actualizar en Firestore
      await _firestore
          .collection('experiences')
          .doc(experienceId)
          .update(updateData);
    } on FirebaseException catch (e) {
      throw Exception('Error actualizando experiencia: $e');
    }
  }

  @override
  Future<void> addReaction(String experienceId, ReactionType reaction) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener UserModel serializado
      final userModel = await _getUserModel(user);

      final reactionData = {
        'id': '${experienceId}_${user.uid}',
        'user': userModel.toJson(), // Usar UserModel serializado
        'type': reaction.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('experiences').doc(experienceId).update({
        'reactions': FieldValue.arrayUnion([reactionData]),
      });
    } on FirebaseException catch (e) {
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
      final doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();
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
    } on FirebaseException catch (e) {
      throw Exception('Error removiendo reacción: $e');
    }
  }

  @override
  Future<void> markAsViewed(String experienceId) async {
    try {
      await _firestore.collection('experiences').doc(experienceId).update({
        'views': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw Exception('Error marcando como vista: $e');
    }
  }

  @override
  Future<void> addViewer(String experienceId, UserEntity viewer) async {
    try {
      final viewerMap = UserModel.fromEntity(viewer).toJson();
      await _firestore.collection('experiences').doc(experienceId).update({
        'viewers': FieldValue.arrayUnion([viewerMap]),
        'views': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw Exception('Error agregando viewer: $e');
    }
  }

  @override
  Stream<List<UserEntity>> watchViewers(String experienceId) {
    return _firestore
        .collection('experiences')
        .doc(experienceId)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return [];
          final data = snap.data() as Map<String, dynamic>;
          final viewersList = data['viewers'] as List? ?? [];
          return viewersList
              .map((v) {
                try {
                  return UserModel.fromJson(
                    v as Map<String, dynamic>,
                  ).toEntity();
                } catch (e) {
                  return null;
                }
              })
              .whereType<UserEntity>()
              .toList();
        });
  }

  @override
  Future<void> repostExperience(
    ExperienceEntity original, {
    String caption = '',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final userModel = await _getUserModel(user);
      final newId = _firestore.collection('experiences').doc().id;

      final mediaList = original.media.asMap().entries.map((entry) {
        final m = entry.value;
        return ExperienceMediaModel(
          id: '${newId}_media_${entry.key}',
          url: m.url,
          mediaType: m.mediaType,
          duration: m.duration,
          aspectRatio: m.aspectRatio,
          thumbnailUrl: m.thumbnailUrl,
          description: m.description,
        );
      }).toList();

      final repostModel = ExperienceModel(
        id: newId,
        description: caption,
        tags: original.tags,
        user: userModel,
        createdAt: DateTime.now(),
        media: mediaList,
        type: original.type,
        format: original.format,
        views: 0,
        reactions: const [],
        viewers: const [],
        isRepost: true,
        originalAuthorUserName: original.user.userName.isNotEmpty
            ? original.user.userName
            : original.user.fullName,
        originalAuthorId: original.user.id.isNotEmpty ? original.user.id : null,
      );

      final data = repostModel.toJson();
      data['originalStoryId'] = original.id;

      await _firestore.collection('experiences').doc(newId).set(data);
    } on FirebaseException catch (e) {
      throw Exception('Error reposteando experiencia: $e');
    }
  }

  @override
  Future<Map<String, String>> getUserReposts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('user.id', isEqualTo: userId)
          .where('isRepost', isEqualTo: true)
          .get();

      final result = <String, String>{};
      for (final doc in snapshot.docs) {
        final originalId = doc.data()['originalStoryId'] as String?;
        if (originalId != null && originalId.isNotEmpty) {
          result[originalId] = doc.id;
        }
      }
      return result;
    } on FirebaseException catch (e) {
      debugPrint('Error obteniendo reposts del usuario: $e');
      return {};
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
      File processedFile = File(filePath);

      // Verificar que el archivo existe
      if (!processedFile.existsSync()) {
        throw Exception('El archivo no existe: $filePath');
      }

      // Optimizar imagen si es necesario
      if (mediaType == MediaType.image) {
        processedFile = await _optimizeImage(processedFile);
      }

      // Leer el archivo procesado como bytes
      final Uint8List fileBytes = await processedFile.readAsBytes();

      // Crear referencia en Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = mediaType == MediaType.video ? 'mp4' : 'jpg';
      final fileName = 'experiences/${experienceId}/${timestamp}.$extension';
      final fileRef = storageRef.child(fileName);

      // Configurar metadata
      final metadata = SettableMetadata(
        contentType: mediaType == MediaType.video ? 'video/mp4' : 'image/jpeg',
        customMetadata: {
          'experienceId': experienceId,
          'userId': _auth.currentUser?.uid ?? 'unknown',
          'uploadedAt': DateTime.now().toIso8601String(),
          'optimized': mediaType == MediaType.image ? 'true' : 'false',
        },
      );

      // Subir archivo usando putData para mayor control
      final uploadTask = fileRef.putData(fileBytes, metadata);

      // Monitorear progreso si se proporciona callback
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Esperar a que termine la subida
      final snapshot = await uploadTask;

      // Obtener URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Limpiar archivo temporal si fue optimizado
      if (mediaType == MediaType.image && processedFile.path != filePath) {
        try {
          await processedFile.delete();
        } on FirebaseException catch (e) {
          // Ignorar errores de limpieza
          debugPrint('Error limpiando archivo temporal: $e');
        }
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Error subiendo archivo: $e');
    }
  }

  /// Optimiza una imagen para reducir su tamaño manteniendo calidad
  Future<File> _optimizeImage(File originalFile) async {
    try {
      // Obtener el tamaño del archivo original
      final originalBytes = await originalFile.readAsBytes();
      final originalSize = originalBytes.length;

      // Si el archivo es menor a 3MB, no optimizar
      if (originalSize < 3 * 1024 * 1024) {
        return originalFile;
      }

      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final optimizedPath = '${tempDir.path}/optimized_$timestamp.jpg';

      // Configuración de compresión conservadora para mantener calidad
      int quality = 92;
      int? targetWidth;
      int? targetHeight;

      // Ajustar calidad segúnn el tamaño del archivo
      if (originalSize > 10 * 1024 * 1024) {
        // Archivos > 10MB: compresión moderada
        quality = 85;
        targetWidth = 1920;
        targetHeight = 2400;
      } else if (originalSize > 5 * 1024 * 1024) {
        // Archivos > 5MB: compresión ligera
        quality = 90;
        targetWidth = 2048;
        targetHeight = 2560;
      }

      // Comprimir imagen
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.absolute.path,
        quality: quality,
        minWidth: targetWidth ?? 1024,
        minHeight: targetHeight ?? 768,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        // Si falla la compresión, usar archivo original
        return originalFile;
      }

      // Escribir archivo optimizado
      final optimizedFile = File(optimizedPath);
      await optimizedFile.writeAsBytes(compressedBytes);

      // Verificar que la optimización fue efectiva
      final optimizedSize = compressedBytes.length;
      final compressionRatio = (1 - (optimizedSize / originalSize)) * 100;

      debugPrint(
        'Imagen optimizada: ${originalSize ~/ 1024}KB a ${optimizedSize ~/ 1024}KB (${compressionRatio.toStringAsFixed(1)}% reducción)',
      );

      // Si la compresión redujo menos del 10%, usar original
      if (compressionRatio < 10) {
        await optimizedFile.delete();
        return originalFile;
      }

      return optimizedFile;
    } catch (e) {
      debugPrint('Error optimizando imagen: $e');
      // En caso de error, usar archivo original
      return originalFile;
    }
  }
}
