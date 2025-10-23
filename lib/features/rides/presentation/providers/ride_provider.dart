import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/shared/services/optimized_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('rides')
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: oneWeekAgo.toIso8601String(),
          )
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Separar rodadas: próximas primero, luego pasadas (última semana)
      final upcomingRides = _rides.where((ride) {
        return ride.dateTime.isAfter(now);
      }).toList();

      final pastRides = _rides.where((ride) {
        return ride.dateTime.isBefore(now) && ride.dateTime.isAfter(oneWeekAgo);
      }).toList();

      // Ordenar: próximas ascendente (más cercanas primero), pasadas descendente (más recientes primero)
      upcomingRides.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      pastRides.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Combinar: próximas + pasadas
      _rides = [...upcomingRides, ...pastRides];

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar las rodadas: $e');
      _setLoading(false);
    }
  }

  // Cargar rodadas por grupo
  Future<void> loadRidesByGroup(String groupId) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('rides')
          .where('groupId', isEqualTo: groupId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: oneWeekAgo.toIso8601String(),
          )
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Separar rodadas: próximas primero, luego pasadas (última semana)
      final upcomingRides = _rides.where((ride) {
        return ride.dateTime.isAfter(now);
      }).toList();

      final pastRides = _rides.where((ride) {
        return ride.dateTime.isBefore(now) && ride.dateTime.isAfter(oneWeekAgo);
      }).toList();

      // Ordenar: próximas ascendente (más cercanas primero), pasadas descendente (más recientes primero)
      upcomingRides.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      pastRides.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Combinar: próximas + pasadas
      _rides = [...upcomingRides, ...pastRides];

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar las rodadas del grupo: $e');
      _setLoading(false);
    }
  }

  // Cargar rodadas del usuario actual
  Future<void> loadUserRides() async {
    if (currentUserId == null) {
      _setError('Usuario no autenticado');
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
    } catch (e) {
      _setError('Error al cargar las rodadas del usuario: $e');
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
      _setError('Usuario no autenticado');
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
            print('Error moviendo imagen temporal, usando URL temporal');
            await docRef.update({'imageUrl': imageUrl});
          }
        } catch (e) {
          print('Error moviendo imagen temporal: $e');
          // Continuar sin la imagen si hay error
        }
      } else if (imageUrl != null) {
        // Imagen normal, actualizarla directamente
        await docRef.update({'imageUrl': imageUrl});
      }

      await loadAllRides();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al crear la rodada: $e');
      _setLoading(false);
      return false;
    }
  }

  // Unirse a una rodada
  Future<bool> joinRide(String rideId, {bool maybe = false}) async {
    if (currentUserId == null) {
      _setError('Usuario no autenticado');
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

      // 🔍 DEBUG: Ver exactamente qué datos tenemos
      print('🔍 DEBUG joinRide - userData completo: $userData');
      print('🔍 DEBUG joinRide - currentUserId: $currentUserId');
      print(
        '🔍 DEBUG joinRide - Firebase Auth displayName: ${_auth.currentUser?.displayName}',
      );
      print(
        '🔍 DEBUG joinRide - Firebase Auth email: ${_auth.currentUser?.email}',
      );
      print(
        '🔍 DEBUG joinRide - Firebase Auth phoneNumber: ${_auth.currentUser?.phoneNumber}',
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
            // Usar teléfono formateado como último recurso
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

        print('🔍 DEBUG joinRide - userName seleccionado: "$userName"');
        print('🔍 DEBUG joinRide - photoUrl seleccionado: "$photoUrl"');
      } else {
        // CRÍTICO: Si no existe el documento en Firestore, crearlo con datos básicos
        print(
          '⚠️ DEBUG joinRide - No se encontró documento de usuario en Firestore',
        );
        print('⚠️ Creando documento básico para el usuario...');

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

          print('✅ Documento de usuario creado/actualizado');
        } catch (e) {
          print('❌ Error creando documento de usuario: $e');
        }
      }

      final participantMetadata = ParticipantMetadata(
        userId: currentUserId!,
        userName: userName,
        photoUrl: photoUrl,
      );

      final rideRef = _firestore.collection('rides').doc(rideId);

      // Obtener rodada actual para actualizar metadata
      final rideDoc = await rideRef.get();
      final rideData = rideDoc.data();

      if (rideData == null) {
        _setError('Rodada no encontrada');
        _setLoading(false);
        return false;
      }

      // Actualizar listas de metadata
      List<Map<String, dynamic>> participantsMetadata =
          (rideData['participantsMetadata'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      List<Map<String, dynamic>> maybeParticipantsMetadata =
          (rideData['maybeParticipantsMetadata'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      // Remover de ambas listas primero
      participantsMetadata.removeWhere((m) => m['userId'] == currentUserId);
      maybeParticipantsMetadata.removeWhere(
        (m) => m['userId'] == currentUserId,
      );

      if (maybe) {
        maybeParticipantsMetadata.add(participantMetadata.toMap());
        await rideRef.update({
          'maybeParticipants': FieldValue.arrayUnion([currentUserId]),
          'participants': FieldValue.arrayRemove([currentUserId]),
          'maybeParticipantsMetadata': maybeParticipantsMetadata,
          'participantsMetadata': participantsMetadata,
        });
      } else {
        participantsMetadata.add(participantMetadata.toMap());
        await rideRef.update({
          'participants': FieldValue.arrayUnion([currentUserId]),
          'maybeParticipants': FieldValue.arrayRemove([currentUserId]),
          'participantsMetadata': participantsMetadata,
          'maybeParticipantsMetadata': maybeParticipantsMetadata,
        });
      }

      // Recargar la rodada actual para actualizar la UI inmediatamente
      await selectRideById(rideId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al unirse a la rodada: $e');
      _setLoading(false);
      return false;
    }
  }

  // Salirse de una rodada
  Future<bool> leaveRide(String rideId) async {
    if (currentUserId == null) {
      _setError('Usuario no autenticado');
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
    } catch (e) {
      _setError('Error al salirse de la rodada: $e');
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

      final querySnapshot = await _firestore
          .collection('rides')
          .where('groupId', isEqualTo: groupId)
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar las rodadas del grupo: $e');
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
      _setError('Usuario no autenticado');
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
    } catch (e) {
      _setError('Error al marcar como "tal vez" en la rodada: $e');
      _setLoading(false);
      return false;
    }
  }

  // Cancelar una rodada (solo el creador puede hacerlo)
  Future<bool> cancelRide(String rideId) async {
    if (currentUserId == null) {
      _setError('Usuario no autenticado');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final rideRef = _firestore.collection('rides').doc(rideId);

      // Verificar que el usuario actual es el creador
      final rideDoc = await rideRef.get();
      if (!rideDoc.exists) {
        _setError('La rodada no existe');
        _setLoading(false);
        return false;
      }

      final rideData = rideDoc.data() as Map<String, dynamic>;
      if (rideData['createdBy'] != currentUserId) {
        _setError('Solo el organizador puede cancelar la rodada');
        _setLoading(false);
        return false;
      }

      // Actualizar el estado de la rodada a cancelado
      await rideRef.update({'status': RideStatus.cancelled.name});

      // Actualizar la rodada seleccionada si es la misma
      if (_selectedRide?.id == rideId) {
        _selectedRide = _selectedRide!.copyWith(status: RideStatus.cancelled);
      }

      await loadAllRides();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al cancelar la rodada: $e');
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
        _setError('Rodada no encontrada');
        _selectedRide = null;
        _setLoading(false);
        return;
      }

      _selectedRide = RideModel.fromFirestore(rideDoc.data()!, rideDoc.id);
      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar la rodada: $e');
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
        'name': groupData['name'] ?? 'Grupo sin nombre',
        'description': groupData['description'] ?? '',
        'memberCount': groupData['numberMembers'] ?? 0,
        'imageUrl': groupData['logo'] ?? groupData['logoUrl'],
        'logoUrl': groupData['logo'] ?? groupData['logoUrl'],
      };
    } catch (e) {
      print('Error al cargar información del grupo: $e');
      return null;
    }
  }
}
