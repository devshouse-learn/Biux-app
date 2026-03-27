import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';

/// Repositorio de pagos con persistencia en Firestore.
/// La pasarela de pagos (Stripe/MercadoPago) se integra desde el backend;
/// este repositorio gestiona el registro y estado de los intents en Firestore.
class PaymentsFirebaseRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'payment_intents';

  /// Crea un payment intent y lo persiste en Firestore.
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? userId,
    String? orderId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final now = DateTime.now().toIso8601String();

      final paymentData = {
        'id': docRef.id,
        'amount': amount,
        'currency': currency,
        'status': 'pending',
        'userId': userId,
        'orderId': orderId,
        'description': description,
        'metadata': metadata ?? {},
        'createdAt': now,
        'updatedAt': now,
      };

      await docRef.set(paymentData);

      AppLogger.info(
        'Payment intent creado: ${docRef.id}',
        tag: 'PaymentsRepo',
      );

      return paymentData;
    } catch (e) {
      AppLogger.error(
        'Error creando payment intent',
        tag: 'PaymentsRepo',
        error: e,
      );
      rethrow;
    }
  }

  /// Confirma un pago actualizando su estado en Firestore.
  Future<bool> confirmPayment(String paymentId) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).update({
        'status': 'confirmed',
        'confirmedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      AppLogger.info('Payment confirmado: $paymentId', tag: 'PaymentsRepo');
      return true;
    } catch (e) {
      AppLogger.error(
        'Error confirmando payment',
        tag: 'PaymentsRepo',
        error: e,
      );
      return false;
    }
  }

  /// Cancela un pago.
  Future<bool> cancelPayment(String paymentId, {String? reason}) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      AppLogger.info('Payment cancelado: $paymentId', tag: 'PaymentsRepo');
      return true;
    } catch (e) {
      AppLogger.error(
        'Error cancelando payment',
        tag: 'PaymentsRepo',
        error: e,
      );
      return false;
    }
  }

  /// Obtiene el historial de pagos de un usuario.
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.error(
        'Error obteniendo pagos del usuario',
        tag: 'PaymentsRepo',
        error: e,
      );
      return [];
    }
  }

  /// Obtiene un pago por ID.
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(paymentId).get();

      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      AppLogger.error(
        'Error obteniendo payment',
        tag: 'PaymentsRepo',
        error: e,
      );
      return null;
    }
  }
}
