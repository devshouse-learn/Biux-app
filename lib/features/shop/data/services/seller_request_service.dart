import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_request_model.dart';
import '../../domain/entities/seller_request_entity.dart';

/// Servicio para gestionar solicitudes de vendedores
class SellerRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Colección de solicitudes
  CollectionReference get _requestsCollection =>
      _firestore.collection('seller_requests');

  /// Colección de usuarios
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Crea una nueva solicitud de vendedor
  Future<String> createSellerRequest({
    required String userId,
    required String userName,
    required String userPhoto,
    required String userEmail,
    required String message,
  }) async {
    try {
      print('📝 Creando solicitud de vendedor para: $userName');

      // Verificar si ya existe una solicitud pendiente
      final existingRequest = await _requestsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        print('⚠️ Ya existe una solicitud pendiente');
        throw Exception('Ya tienes una solicitud pendiente de revisión');
      }

      final request = SellerRequestModel(
        id: '', // Se generará automáticamente
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        userEmail: userEmail,
        message: message,
        status: SellerRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef = await _requestsCollection.add(request.toMap());

      print('✅ Solicitud creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creando solicitud: $e');
      rethrow;
    }
  }

  /// Obtiene todas las solicitudes pendientes
  Stream<List<SellerRequestEntity>> getPendingRequests() {
    return _requestsCollection
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SellerRequestModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Obtiene todas las solicitudes
  Stream<List<SellerRequestEntity>> getAllRequests() {
    return _requestsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SellerRequestModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Obtiene las solicitudes de un usuario específico
  Stream<List<SellerRequestEntity>> getUserRequests(String userId) {
    return _requestsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SellerRequestModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Aprueba una solicitud de vendedor
  Future<void> approveRequest({
    required String requestId,
    required String adminId,
    String? comment,
  }) async {
    try {
      print('✅ Aprobando solicitud: $requestId');

      // Obtener la solicitud
      final requestDoc = await _requestsCollection.doc(requestId).get();
      if (!requestDoc.exists) {
        throw Exception('Solicitud no encontrada');
      }

      final request = SellerRequestModel.fromFirestore(requestDoc);

      // Actualizar la solicitud
      await _requestsCollection.doc(requestId).update({
        'status': 'approved',
        'reviewedAt': Timestamp.now(),
        'reviewedBy': adminId,
        'reviewComment': comment ?? 'Solicitud aprobada',
      });

      // Actualizar el usuario para que sea vendedor
      await _usersCollection.doc(request.userId).update({
        'canSellProducts': true,
        'autorizadoPorAdmin': true,
        'role': 'seller',
        'authorizedAt': Timestamp.now(),
        'authorizedBy': adminId,
      });

      print('✅ Usuario ${request.userName} ahora es vendedor autorizado');
    } catch (e) {
      print('❌ Error aprobando solicitud: $e');
      rethrow;
    }
  }

  /// Rechaza una solicitud de vendedor
  Future<void> rejectRequest({
    required String requestId,
    required String adminId,
    String? comment,
  }) async {
    try {
      print('❌ Rechazando solicitud: $requestId');

      await _requestsCollection.doc(requestId).update({
        'status': 'rejected',
        'reviewedAt': Timestamp.now(),
        'reviewedBy': adminId,
        'reviewComment': comment ?? 'Solicitud rechazada',
      });

      print('✅ Solicitud rechazada');
    } catch (e) {
      print('❌ Error rechazando solicitud: $e');
      rethrow;
    }
  }

  /// Elimina una solicitud
  Future<void> deleteRequest(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).delete();
      print('🗑️ Solicitud eliminada: $requestId');
    } catch (e) {
      print('❌ Error eliminando solicitud: $e');
      rethrow;
    }
  }

  /// Verifica si un usuario tiene una solicitud pendiente
  Future<bool> hasPendingRequest(String userId) async {
    try {
      final snapshot = await _requestsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando solicitud pendiente: $e');
      return false;
    }
  }

  /// Obtiene el conteo de solicitudes pendientes
  Stream<int> getPendingRequestsCount() {
    return _requestsCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
