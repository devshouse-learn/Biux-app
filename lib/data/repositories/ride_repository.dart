import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ride_model.dart';

class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear una nueva rodada
  Future<String?> createRide(RideModel ride) async {
    try {
      final docRef =
          await _firestore.collection('rides').add(ride.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating ride: $e');
      return null;
    }
  }

  // Obtener rodadas de un grupo específico
  Stream<List<RideModel>> getGroupRides(String groupId) {
    return _firestore
        .collection('rides')
        .where('groupId', isEqualTo: groupId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Obtener TODAS las rodadas de todos los grupos
  Stream<List<RideModel>> getAllRides() {
    return _firestore
        .collection('rides')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Obtener una rodada específica
  Future<RideModel?> getRideById(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists && doc.data() != null) {
        return RideModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting ride: $e');
      return null;
    }
  }

  // Unirse a una rodada (confirmar asistencia)
  Future<bool> joinRide(String rideId, String userId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'maybeParticipants':
            FieldValue.arrayRemove([userId]), // Remover de "tal vez"
      });
      return true;
    } catch (e) {
      print('Error joining ride: $e');
      return false;
    }
  }

  // Marcar como "tal vez voy"
  Future<bool> maybeJoinRide(String rideId, String userId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'maybeParticipants': FieldValue.arrayUnion([userId]),
        'participants':
            FieldValue.arrayRemove([userId]), // Remover de confirmados
      });
      return true;
    } catch (e) {
      print('Error marking maybe join ride: $e');
      return false;
    }
  }

  // Salir de una rodada
  Future<bool> leaveRide(String rideId, String userId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'maybeParticipants': FieldValue.arrayRemove([userId]),
      });
      return true;
    } catch (e) {
      print('Error leaving ride: $e');
      return false;
    }
  }

  // Actualizar una rodada
  Future<bool> updateRide(String rideId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('rides').doc(rideId).update(updates);
      return true;
    } catch (e) {
      print('Error updating ride: $e');
      return false;
    }
  }

  // Cancelar una rodada
  Future<bool> cancelRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.cancelled.name,
      });
      return true;
    } catch (e) {
      print('Error cancelling ride: $e');
      return false;
    }
  }

  // Eliminar una rodada
  Future<bool> deleteRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).delete();
      return true;
    } catch (e) {
      print('Error deleting ride: $e');
      return false;
    }
  }

  // Obtener rodadas donde el usuario participa
  Stream<List<RideModel>> getUserRides(String userId) {
    return _firestore
        .collection('rides')
        .where('participants', arrayContains: userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Obtener próximas rodadas (todas)
  Stream<List<RideModel>> getUpcomingRides() {
    final now = DateTime.now();
    return _firestore
        .collection('rides')
        .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: RideStatus.upcoming.name)
        .orderBy('dateTime', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
