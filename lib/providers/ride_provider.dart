import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/models/ride_model.dart';

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

      final querySnapshot = await _firestore
          .collection('rides')
          .orderBy('dateTime', descending: false)
          .get();

      _rides = querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
          .toList();

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

      await _firestore.collection('rides').add(rideData);
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

      final rideRef = _firestore.collection('rides').doc(rideId);

      if (maybe) {
        await rideRef.update({
          'maybeParticipants': FieldValue.arrayUnion([currentUserId]),
          'participants': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        await rideRef.update({
          'participants': FieldValue.arrayUnion([currentUserId]),
          'maybeParticipants': FieldValue.arrayRemove([currentUserId]),
        });
      }

      await loadAllRides();
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
      await rideRef.update({
        'participants': FieldValue.arrayRemove([currentUserId]),
        'maybeParticipants': FieldValue.arrayRemove([currentUserId]),
      });

      await loadAllRides();
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
      await rideRef.update({
        'status': RideStatus.cancelled.name,
      });

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
        'memberCount': groupData['memberCount'] ?? 0,
        'imageUrl': groupData['imageUrl'],
        'logoUrl': groupData['logoUrl'],
      };
    } catch (e) {
      print('Error al cargar información del grupo: $e');
      return null;
    }
  }
}
