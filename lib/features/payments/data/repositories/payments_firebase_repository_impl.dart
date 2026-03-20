import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/payments/domain/repositories/payments_repository_abstract.dart';

/// Implementación de pagos con Firebase/Firestore.
///
/// Persiste intents de pago en Firestore (colección `payment_intents`)
/// y delega la confirmación real a una Cloud Function que se comunica
/// con la pasarela configurada (MercadoPago / Stripe).
class PaymentsFirebaseRepositoryImpl extends PaymentsRepositoryAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'payment_intents';

  @override
  Future<String> gatewayPayment() async {
    // Crea un intent genérico; la Cloud Function se encargará
    // de devolver la URL de la pasarela de pago.
    final intent = await createPaymentIntent(
      amount: 0,
      currency: 'COP',
      metadata: {'source': 'gateway_payment'},
    );
    return intent['id'] as String;
  }

  /// Crea un intent de pago y lo registra en Firestore.
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? userId,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = {
        'amount': amount,
        'currency': currency,
        'userId': userId,
        'orderId': orderId,
        'status': 'requires_confirmation',
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection(_collection).add(data);

      return {
        'id': docRef.id,
        'amount': amount,
        'currency': currency,
        'status': 'requires_confirmation',
      };
    } catch (e) {
      throw Exception('Error creando intent de pago: $e');
    }
  }

  /// Confirma un pago actualizando su estado en Firestore.
  Future<bool> confirmPayment(String paymentId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(paymentId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Payment intent no encontrado: $paymentId');
      }

      await docRef.update({
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Error confirmando pago: $e');
    }
  }

  /// Cancela un pago.
  Future<bool> cancelPayment(String paymentId) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      throw Exception('Error cancelando pago: $e');
    }
  }

  /// Obtiene el estado de un pago.
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(paymentId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw Exception('Error consultando pago: $e');
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
      throw Exception('Error obteniendo pagos del usuario: $e');
    }
  }
}
