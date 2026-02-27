import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:biux/features/experiences/domain/entities/experience_entity.dart';
import 'package:biux/features/experiences/domain/repositories/experience_repository.dart';
import 'package:biux/features/experiences/data/models/experience_model.dart';

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
    } catch (e) {
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
  Future<ExperienceEntity?> getExperienceById(String experienceId) async {
    try {
      final doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();

      if (!doc.exists) {
        print('⚠️ REPO: Experiencia no encontrada: $experienceId');
        return null;
      }

      return ExperienceModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      }).toEntity();
    } catch (e) {
      print('❌ REPO: Error obteniendo experiencia por ID: $e');
      throw Exception('Error obteniendo experiencia: $e');
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
      print(
        '🔍 REPO: Obteniendo experiencias de usuarios seguidos para: $userId',
      );

      // Primero intentar obtener de subcolección
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      List<String> followingIds = followingSnapshot.docs
          .map((doc) => doc.id)
          .toList();
      print(
        '🔍 REPO: Usuarios seguidos en subcolección: ${followingIds.length}',
      );

      // Si no hay en subcolección, intentar desde el documento principal
      if (followingIds.isEmpty) {
        print('🔍 REPO: Buscando en documento principal del usuario...');
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          // Verificar si hay campo "following" como Map
          if (userData['following'] is Map) {
            final followingMap = userData['following'] as Map;
            followingIds = followingMap.keys.cast<String>().toList();
            print(
              '🔍 REPO: Usuarios seguidos en documento principal: ${followingIds.length}',
            );
            print('🔍 REPO: Following map: $followingMap');
          }
        }
      }

      print('🔍 REPO: Total IDs de usuarios seguidos: $followingIds');

      if (followingIds.isEmpty) {
        print('⚠️ REPO: No hay usuarios seguidos, retornando lista vacía');
        return [];
      }

      // Obtener experiencias de usuarios seguidos
      final snapshot = await _firestore
          .collection('experiences')
          .where('user.id', whereIn: followingIds)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      print(
        '🔍 REPO: Experiencias de seguidos encontradas: ${snapshot.docs.length}',
      );

      return snapshot.docs
          .map(
            (doc) => ExperienceModel.fromJson({
              'id': doc.id,
              ...doc.data(),
            }).toEntity(),
          )
          .toList();
    } catch (e) {
      print('❌ REPO: Error obteniendo experiencias de seguidores: $e');
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
          // PENDIENTE: Implementar generación de thumbnail
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
      final doc = await _firestore
          .collection('experiences')
          .doc(experienceId)
          .get();
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
          final url = mediaItem['url'] as String;
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
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
  Future<void> updateExperience(
    String experienceId, {
    required String description,
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

      // Actualizar la descripción
      await _firestore.collection('experiences').doc(experienceId).update({
        'description': description,
      });
    } catch (e) {
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
        } catch (e) {
          // Ignorar errores de limpieza
          print('Error limpiando archivo temporal: $e');
        }
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Error subiendo archivo: $e');
    }
  }

  /// Optimiza una imagen para reducir su tamaño manteniendo calidad
  Future<File> _optimizeImage(File originalFile) async {
    try {
      // Obtener el tamaño del archivo original
      final originalBytes = await originalFile.readAsBytes();
      final originalSize = originalBytes.length;

      // Si el archivo es menor a 1MB, no optimizar
      if (originalSize < 1024 * 1024) {
        return originalFile;
      }

      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final optimizedPath = '${tempDir.path}/optimized_$timestamp.jpg';

      // Configuración de compresión adaptativa
      int quality = 85;
      int? targetWidth;
      int? targetHeight;

      // Ajustar calidad según el tamaño del archivo
      if (originalSize > 5 * 1024 * 1024) {
        // Archivos > 5MB: compresión más agresiva
        quality = 70;
        targetWidth = 1920;
        targetHeight = 1080;
      } else if (originalSize > 2 * 1024 * 1024) {
        // Archivos > 2MB: compresión moderada
        quality = 80;
        targetWidth = 2048;
        targetHeight = 1536;
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

      print(
        'Imagen optimizada: ${originalSize ~/ 1024}KB → ${optimizedSize ~/ 1024}KB (${compressionRatio.toStringAsFixed(1)}% reducción)',
      );

      // Si la compresión redujo menos del 10%, usar original
      if (compressionRatio < 10) {
        await optimizedFile.delete();
        return originalFile;
      }

      return optimizedFile;
    } catch (e) {
      print('Error optimizando imagen: $e');
      // En caso de error, usar archivo original
      return originalFile;
    }
  }
}
