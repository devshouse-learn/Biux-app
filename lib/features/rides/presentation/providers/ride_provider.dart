import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/core/services/optimized_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:biux/core/services/app_logger.dart';

enum RideParticipationStatus {
  notParticipating,
  participating,
  maybeParticipating,
}

class RideProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RideModel> _rides = [];
  List<RideModel> _userRides = [];
  RideModel? _selectedRide;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RideModel> get rides => _rides;
  List<RideModel> get userRides => _userRides;
  RideModel? get selectedRide => _selectedRide;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _auth.currentUser?.uid;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cargar todas las rodadas
  Future<void> loadAllRides() async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('rides')
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('error_loading_rides');
      _setLoading(false);
    }
  }

  // Cargar rodadas por grupo
  Future<void> loadRidesByGroup(String groupId) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('rides')
          .where('groupId', isEqualTo: groupId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('error_loading_rides');
      _setLoading(false);
    }
  }

  // Cargar rodadas del usuario actual
  Future<void> loadUserRides() async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('rides')
          .where('participants', arrayContains: currentUserId)
          .orderBy('dateTime', descending: false)
          .get();

      _userRides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } on FirebaseException catch (e) {
      _setError('error_loading_rides');
      _setLoading(false);
    }
  }

  // Crear una nueva rodada
  Future<bool> createRide({
    required String name,
    required String groupId,
    required String meetingPointId,
    required DateTime dateTime,
    required DifficultyLevel difficulty,
    required double kilometers,
    required String instructions,
    required String recommendations,
    String? imageUrl, // Imagen opcional de la rodada
  }) async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return false;
    }
    // Validar que la fecha no sea en el pasado
    if (dateTime.isBefore(DateTime.now())) {
      _setError('ride_date_cannot_be_past');
      return false;
    }
    // Validar kilómetros
    if (kilometers <= 0) {
      _setError('ride_km_must_be_positive');
      return false;
    }
    // Validar nombre mínimo
    if (name.trim().length < 3) {
      _setError('ride_name_min_chars');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final rideData = {
        'name': name,
        'groupId': groupId,
        'meetingPointId': meetingPointId,
        'dateTime': Timestamp.fromDate(dateTime),
        'difficulty': difficulty.name,
        'kilometers': kilometers,
        'instructions': instructions,
        'recommendations': recommendations,
        'createdBy': currentUserId,
        'createdAt': Timestamp.now(),
        'status': RideStatus.upcoming.name,
        'participants': <String>[],
        'maybeParticipants': <String>[],
      };

      // Crear la rodada primero para obtener el ID
      final docRef = await _firestore.collection('rides').add(rideData);
      final rideId = docRef.id;

      // Si hay imagen temporal, moverla al lugar correcto
      if (imageUrl != null && imageUrl.contains('temp_')) {
        try {
          final finalImageUrl =
              await OptimizedStorageService.moveTemporaryRideImage(
                tempImageUrl: imageUrl,
                rideId: rideId,
              );

          if (finalImageUrl != null) {
            await docRef.update({'imageUrl': finalImageUrl});
          } else {
            AppLogger.warning(
              'Error moviendo imagen temporal, usando URL temporal',
              tag: 'RideProvider',
            );
            await docRef.update({'imageUrl': imageUrl});
          }
        } on FirebaseException catch (e) {
          AppLogger.error(
            'Error moviendo imagen temporal',
            error: e,
            tag: 'RideProvider',
          );
          // Continuar sin la imagen si hay error
        }
      } else if (imageUrl != null) {
        // Imagen normal, actualizarla directamente
        await docRef.update({'imageUrl': imageUrl});
      }

      await loadAllRides();

      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError('error_creating_ride');
      _setLoading(false);
      return false;
    }
  }

  // Actualizar una rodada existente
  Future<bool> updateRide({
    required String rideId,
    required String name,
    required String meetingPointId,
    required DateTime dateTime,
    required DifficultyLevel difficulty,
    required double kilometers,
    required String instructions,
    required String recommendations,
    String? imageUrl, // Nueva imagen (puede ser null para mantener la actual)
    bool removeImage = false, // Flag para eliminar la imagen actual
  }) async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Verificar que el usuario es el creador de la rodada
      final rideDoc = await _firestore.collection('rides').doc(rideId).get();
      if (!rideDoc.exists) {
        _setError('ride_not_found');
        _setLoading(false);
        return false;
      }

      final rideData = rideDoc.data()!;
      if (rideData['createdBy'] != currentUserId) {
        _setError('no_permission_edit_ride');
        _setLoading(false);
        return false;
      }

      // Preparar datos de actualización
      final updateData = {
        'name': name,
        'meetingPointId': meetingPointId,
        'dateTime': Timestamp.fromDate(dateTime),
        'difficulty': difficulty.name,
        'kilometers': kilometers,
        'instructions': instructions,
        'recommendations': recommendations,
        'updatedAt': Timestamp.now(),
      };

      // Manejo de la imagen
      final currentImageUrl = rideData['imageUrl'] as String?;

      if (removeImage) {
        // Eliminar imagen actual si existe
        if (currentImageUrl != null) {
          try {
            await OptimizedStorageService.deleteImage(currentImageUrl);
          } on FirebaseException catch (e) {
            AppLogger.error(
              'Error eliminando imagen anterior',
              error: e,
              tag: 'RideProvider',
            );
          }
        }
        updateData['imageUrl'] = FieldValue.delete();
      } else if (imageUrl != null && imageUrl != currentImageUrl) {
        // Nueva imagen proporcionada
        if (imageUrl.contains('temp_')) {
          // Mover imagen temporal
          try {
            final finalImageUrl =
                await OptimizedStorageService.moveTemporaryRideImage(
                  tempImageUrl: imageUrl,
                  rideId: rideId,
                );

            if (finalImageUrl != null) {
              updateData['imageUrl'] = finalImageUrl;
            } else {
              updateData['imageUrl'] = imageUrl;
            }
          } on FirebaseException catch (e) {
            AppLogger.error(
              'Error moviendo imagen temporal',
              error: e,
              tag: 'RideProvider',
            );
            updateData['imageUrl'] = imageUrl;
          }
        } else {
          // Imagen normal
          updateData['imageUrl'] = imageUrl;
        }

        // Eliminar imagen anterior si existe
        if (currentImageUrl != null) {
          try {
            await OptimizedStorageService.deleteImage(currentImageUrl);
          } on FirebaseException catch (e) {
            AppLogger.error(
              'Error eliminando imagen anterior',
              error: e,
              tag: 'RideProvider',
            );
          }
        }
      }
      // Si imageUrl es null y removeImage es false, mantener la imagen actual (no hacer nada)

      // Actualizar en Firestore
      await _firestore.collection('rides').doc(rideId).update(updateData);

      // Recargar rodadas y actualizar la seleccionada
      await loadAllRides();
      await selectRideById(rideId);

      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError('error_updating_ride');
      _setLoading(false);
      return false;
    }
  }

  // Unirse a una rodada
  Future<bool> joinRide(String rideId, {bool maybe = false}) async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Obtener datos del usuario actual
      // IMPORTANTE: Usar la colección 'users' (no 'usuarios')
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userDoc.data();

      // 🔗” DEBUG: Ver exactamente qué datos tenemos
      AppLogger.debug(
        'DEBUG joinRide - Firebase Auth displayName: ${_auth.currentUser?.displayName}',
        tag: 'RideProvider',
      );
      AppLogger.debug(
        'DEBUG joinRide - Firebase Auth email: ${_auth.currentUser?.email}',
        tag: 'RideProvider',
      );
      AppLogger.debug(
        'DEBUG joinRide - Firebase Auth phoneNumber: ${_auth.currentUser?.phoneNumber}',
        tag: 'RideProvider',
      );

      // Crear metadata del participante con fallbacks
      String userName = 'Usuario';
      String? photoUrl;

      if (userData != null && userData.isNotEmpty) {
        // Intentar todos los campos posibles de Firestore
        // IMPORTANTE: También revisar si el valor no es una cadena vacía
        String? fullName = userData['fullName'];
        String? userNameField = userData['userName'];
        String? usernameField = userData['username'];
        String? nameField = userData['name'];

        // Buscar el primer campo que NO esté vacío
        userName =
            (fullName != null && fullName.trim().isNotEmpty
                ? fullName
                : null) ??
            (userNameField != null && userNameField.trim().isNotEmpty
                ? userNameField
                : null) ??
            (usernameField != null && usernameField.trim().isNotEmpty
                ? usernameField
                : null) ??
            (nameField != null && nameField.trim().isNotEmpty
                ? nameField
                : null) ??
            userData['full_name'] ??
            userData['displayName'] ??
            _auth.currentUser?.displayName ??
            // Usar teléfono formateado como Ãºltimo recurso
            (_auth.currentUser?.phoneNumber
                    ?.replaceAll('phone_', '')
                    .replaceAll('+57', '') ??
                'Usuario');

        photoUrl =
            userData['photo'] ??
            userData['photoUrl'] ??
            userData['photo_url'] ??
            userData['profilePicture'] ??
            userData['avatar'] ??
            _auth.currentUser?.photoURL;
      } else {
        // CRÃTICO: Si no existe el documento en Firestore, crearlo con datos básicos
        AppLogger.warning(
          'DEBUG joinRide - No se encontró documento de usuario en Firestore',
          tag: 'RideProvider',
        );
        AppLogger.debug(
          'Creando documento básico para el usuario...',
          tag: 'RideProvider',
        );

        // Usar teléfono como nombre temporal si no hay displayName
        userName =
            _auth.currentUser?.displayName ??
            _auth.currentUser?.phoneNumber
                ?.replaceAll('phone_', '')
                .replaceAll('+57', '') ??
            _auth.currentUser?.email?.split('@').first ??
            'Usuario';
        photoUrl = _auth.currentUser?.photoURL;

        // Crear documento básico en Firestore con la colección correcta
        try {
          await _firestore.collection('users').doc(currentUserId).set(
            {
              'fullName': userName,
              'userName': userName,
              'phoneNumber': _auth.currentUser?.phoneNumber ?? '',
              'email': _auth.currentUser?.email ?? '',
              'photo': photoUrl,
              'createdAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          ); // merge: true para no sobrescribir si existe
        } on FirebaseException catch (e) {
          AppLogger.error(
            'Error creando documento de usuario',
            error: e,
            tag: 'RideProvider',
          );
        }
      }

      final participantMetadata = ParticipantMetadata(
        userId: currentUserId!,
        userName: userName,
        photoUrl: photoUrl,
      );

      final rideRef = _firestore.collection('rides').doc(rideId);

      // Usar transacción para evitar race conditions con metadata
      await _firestore.runTransaction((transaction) async {
        final rideDoc = await transaction.get(rideRef);
        final rideData = rideDoc.data();

        if (rideData == null) {
          throw Exception('Rodada no encontrada');
        }

        // Actualizar listas de metadata
        List<Map<String, dynamic>> participantsMetadata =
            (rideData['participantsMetadata'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];
        List<Map<String, dynamic>> maybeParticipantsMetadata =
            (rideData['maybeParticipantsMetadata'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];

        // Remover de ambas listas primero
        participantsMetadata.removeWhere((m) => m['userId'] == currentUserId);
        maybeParticipantsMetadata.removeWhere(
          (m) => m['userId'] == currentUserId,
        );

        if (maybe) {
          maybeParticipantsMetadata.add(participantMetadata.toMap());
          transaction.update(rideRef, {
            'maybeParticipants': FieldValue.arrayUnion([currentUserId]),
            'participants': FieldValue.arrayRemove([currentUserId]),
            'maybeParticipantsMetadata': maybeParticipantsMetadata,
            'participantsMetadata': participantsMetadata,
          });
        } else {
          participantsMetadata.add(participantMetadata.toMap());
          transaction.update(rideRef, {
            'participants': FieldValue.arrayUnion([currentUserId]),
            'maybeParticipants': FieldValue.arrayRemove([currentUserId]),
            'participantsMetadata': participantsMetadata,
            'maybeParticipantsMetadata': maybeParticipantsMetadata,
          });
        }
      });

      // Recargar la rodada actual para actualizar la UI inmediatamente
      await selectRideById(rideId);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError('error_joining_ride');
      _setLoading(false);
      return false;
    }
  }

  // Salirse de una rodada
  Future<bool> leaveRide(String rideId) async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final rideRef = _firestore.collection('rides').doc(rideId);

      // Obtener rodada actual para actualizar metadata
      final rideDoc = await rideRef.get();
      final rideData = rideDoc.data();

      if (rideData != null) {
        // Actualizar listas de metadata
        List<Map<String, dynamic>> participantsMetadata =
            (rideData['participantsMetadata'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        List<Map<String, dynamic>> maybeParticipantsMetadata =
            (rideData['maybeParticipantsMetadata'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];

        // Remover de ambas listas
        participantsMetadata.removeWhere((m) => m['userId'] == currentUserId);
        maybeParticipantsMetadata.removeWhere(
          (m) => m['userId'] == currentUserId,
        );

        await rideRef.update({
          'participants': FieldValue.arrayRemove([currentUserId]),
          'maybeParticipants': FieldValue.arrayRemove([currentUserId]),
          'participantsMetadata': participantsMetadata,
          'maybeParticipantsMetadata': maybeParticipantsMetadata,
        });
      } else {
        // Fallback si no hay data
        await rideRef.update({
          'participants': FieldValue.arrayRemove([currentUserId]),
          'maybeParticipants': FieldValue.arrayRemove([currentUserId]),
        });
      }

      // Recargar la rodada actual para actualizar la UI inmediatamente
      await selectRideById(rideId);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError('error_leaving_ride');
      _setLoading(false);
      return false;
    }
  }

  // Seleccionar una rodada específica
  void selectRide(RideModel ride) {
    _selectedRide = ride;
    notifyListeners();
  }

  // Limpiar la rodada seleccionada
  void clearSelectedRide() {
    _selectedRide = null;
    notifyListeners();
  }

  // Cargar rodadas por grupo (método que faltaba)
  Future<void> loadGroupRides(String groupId) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('rides')
          .where('groupId', isEqualTo: groupId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('error_loading_rides');
      _setLoading(false);
    }
  }

  // Obtener el estado de participación del usuario actual en una rodada
  RideParticipationStatus getParticipationStatus(RideModel ride) {
    if (currentUserId == null) return RideParticipationStatus.notParticipating;

    if (ride.participants.contains(currentUserId)) {
      return RideParticipationStatus.participating;
    } else if (ride.maybeParticipants.contains(currentUserId)) {
      return RideParticipationStatus.maybeParticipating;
    } else {
      return RideParticipationStatus.notParticipating;
    }
  }

  // Verificar si el usuario actual es el creador de la rodada
  bool isCreator(RideModel ride) {
    return currentUserId != null && ride.createdBy == currentUserId;
  }

  // Unirse a una rodada como "tal vez"
  Future<bool> maybeJoinRide(String rideId) async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final rideRef = _firestore.collection('rides').doc(rideId);
      await rideRef.update({
        'maybeParticipants': FieldValue.arrayUnion([currentUserId]),
        'participants': FieldValue.arrayRemove([currentUserId]),
      });

      await loadAllRides();
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError('error_joining_ride');
      _setLoading(false);
      return false;
    }
  }

  // Cancelar una rodada (solo el creador puede hacerlo)
  Future<bool> cancelRide(String rideId) async {
    if (currentUserId == null) {
      _setError('user_not_authenticated');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final rideRef = _firestore.collection('rides').doc(rideId);

      // Verificar que el usuario actual es el creador
      final rideDoc = await rideRef.get();
      if (!rideDoc.exists) {
        _setError('ride_not_found');
        _setLoading(false);
        return false;
      }

      final rideData = rideDoc.data() as Map<String, dynamic>;
      if (rideData['createdBy'] != currentUserId) {
        _setError('only_organizer_can_cancel');
        _setLoading(false);
        return false;
      }

      // Actualizar el estado de la rodada a cancelado
      await rideRef.update({'status': RideStatus.cancelled.name});

      // Actualizar la rodada seleccionada si es la misma
      if (_selectedRide?.id == rideId) {
        if (_selectedRide == null) return false;
        _selectedRide = _selectedRide!.copyWith(status: RideStatus.cancelled);
      }

      await loadAllRides();
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError('error_cancelling_ride');
      _setLoading(false);
      return false;
    }
  }

  // Seleccionar una rodada por ID
  Future<void> selectRideById(String rideId) async {
    try {
      _setLoading(true);
      _setError(null);

      final rideDoc = await _firestore.collection('rides').doc(rideId).get();

      if (!rideDoc.exists) {
        _setError('ride_not_found');
        _selectedRide = null;
        _setLoading(false);
        return;
      }

      _selectedRide = RideModel.fromFirestore(rideDoc.data()!, rideDoc.id);
      _setLoading(false);
    } on FirebaseException catch (e) {
      _setError('error_loading_rides');
      _selectedRide = null;
      _setLoading(false);
    }
  }

  // Obtener información del grupo de una rodada
  Future<Map<String, dynamic>?> getGroupInfo(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        return null;
      }

      final groupData = groupDoc.data()!;
      return {
        'id': groupDoc.id,
        'name': groupData['name'] ?? 'group_no_name',
        'description': groupData['description'] ?? '',
        'memberCount': groupData['numberMembers'] ?? 0,
        'imageUrl': groupData['logo'] ?? groupData['logoUrl'],
        'logoUrl': groupData['logo'] ?? groupData['logoUrl'],
      };
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error al cargar información del grupo',
        error: e,
        tag: 'RideProvider',
      );
      return null;
    }
  }

  // Filtros
  String _filterDifficulty = 'all';
  String _searchQuery = '';
  DateTime? _filterFromDate;

  String get filterDifficulty => _filterDifficulty;
  String get searchQuery => _searchQuery;

  void setFilterDifficulty(String difficulty) {
    _filterDifficulty = difficulty;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void setFilterFromDate(DateTime? date) {
    _filterFromDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _filterDifficulty = 'all';
    _searchQuery = '';
    _filterFromDate = null;
    notifyListeners();
  }

  /// Rides filtrados segúnn criterios activos
  List<dynamic> get filteredRides {
    var list = rides.toList();
    if (_filterDifficulty != 'all') {
      list = list
          .where((r) => r.difficulty.toString().contains(_filterDifficulty))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((r) => r.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    if (_filterFromDate != null) {
      list = list.where((r) {
        final date = r.dateTime;
        return date.isAfter(_filterFromDate!);
      }).toList();
    }
    return list;
  }

  // Paginación
  // ignore: unused_field
  static const int _pageSize = 15;
  // ignore: unused_field
  DocumentSnapshot? _lastDocument;
  bool _hasMoreRides = true;
  bool get hasMoreRides => _hasMoreRides;

  void resetPagination() {
    _lastDocument = null;
    _hasMoreRides = true;
  }
}
