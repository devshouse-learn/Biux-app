import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyDatasource {
  final FirebaseFirestore _firestore;

  EmergencyDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getContacts(String userId) async {
    final doc = await _firestore
        .collection('emergency_contacts')
        .doc(userId)
        .get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    return List<Map<String, dynamic>>.from(data['contacts'] ?? []);
  }

  Future<void> saveContacts(
    String userId,
    List<Map<String, dynamic>> contacts,
  ) async {
    await _firestore.collection('emergency_contacts').doc(userId).set({
      'userId': userId,
      'contacts': contacts,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendSOS(
    String userId, {
    required String userName,
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    await _firestore.collection('sos_alerts').add({
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'message': message ?? 'Alerta de emergencia',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelSOS(String alertId) async {
    await _firestore.collection('sos_alerts').doc(alertId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}
