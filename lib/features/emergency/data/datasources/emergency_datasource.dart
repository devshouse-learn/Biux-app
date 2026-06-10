import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/app_logger.dart';

class EmergencyDatasource {
  final FirebaseFirestore _firestore;

  EmergencyDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ALTO: Validar entrada
  Future<List<Map<String, dynamic>>> getContacts(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException('userId', 'Usuario ID no puede estar vacío');
      }

      final doc = await _firestore
          .collection('emergency_contacts')
          .doc(userId)
          .get();
      if (!doc.exists) return [];
      final data = doc.data()!;
      return List<Map<String, dynamic>>.from(data['contacts'] ?? []);
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'EmergencyDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error obteniendo contactos de emergencia: $e',
          tag: 'EmergencyDatasource', error: e);
      return [];
    }
  }

  /// ALTO: Validar entrada y limitar número de contactos
  Future<void> saveContacts(
    String userId,
    List<Map<String, dynamic>> contacts,
  ) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException('userId', 'Usuario ID no puede estar vacío');
      }

      // Validar cantidad de contactos (máximo 5)
      if (contacts.length > 5) {
        throw ValidationException('contacts',
            'Se permiten máximo 5 contactos de emergencia');
      }

      await _firestore.collection('emergency_contacts').doc(userId).set({
        'userId': userId,
        'contacts': contacts,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Contactos de emergencia guardados: ${contacts.length}',
          tag: 'EmergencyDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'EmergencyDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error guardando contactos: $e',
          tag: 'EmergencyDatasource', error: e);
      rethrow;
    }
  }

  /// ALTO: Validar coordenadas geográficas
  Future<void> sendSOS(
    String userId, {
    required String userName,
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    try {
      if (userId.isEmpty || userName.isEmpty) {
        throw ValidationException('input',
            'Usuario ID y nombre no pueden estar vacíos');
      }

      // Validar coordenadas GPS (lat ±90, lng ±180)
      if (latitude < -90 || latitude > 90) {
        throw ValidationException('latitude',
            'Latitud debe estar entre -90 y 90');
      }
      if (longitude < -180 || longitude > 180) {
        throw ValidationException('longitude',
            'Longitud debe estar entre -180 y 180');
      }

      await _firestore.collection('sos_alerts').add({
        'userId': userId,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
        'message': message ?? 'Alerta de emergencia',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.warning('Alerta SOS enviada para usuario: $userId',
          tag: 'EmergencyDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida en SOS: ${e.message}',
          tag: 'EmergencyDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error enviando SOS: $e',
          tag: 'EmergencyDatasource', error: e);
      rethrow;
    }
  }

  /// ALTO: Validar entrada y verificar autorización
  Future<void> cancelSOS(String alertId, String userId) async {
    try {
      if (alertId.isEmpty || userId.isEmpty) {
        throw ValidationException('input',
            'Alert ID y Usuario ID no pueden estar vacíos');
      }

      // Verificar que la alerta existe y pertenece al usuario
      final alertDoc = await _firestore
          .collection('sos_alerts')
          .doc(alertId)
          .get();

      if (!alertDoc.exists) {
        throw Exception('Alert not found');
      }

      final alertData = alertDoc.data()!;
      if (alertData['userId'] != userId) {
        AppLogger.warning(
            'Intento no autorizado de cancelar SOS - Usuario: $userId, Propietario: ${alertData['userId']}',
            tag: 'EmergencyDatasource');
        throw UnauthorizedException('cancelar esta alerta SOS');
      }

      await _firestore.collection('sos_alerts').doc(alertId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Alerta SOS cancelada: $alertId',
          tag: 'EmergencyDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'EmergencyDatasource');
      rethrow;
    } on UnauthorizedException catch (e) {
      AppLogger.warning('No autorizado: ${e.message}',
          tag: 'EmergencyDatasource');
      rethrow;
    } catch (e) {
      AppLogger.error('Error cancelando SOS: $e',
          tag: 'EmergencyDatasource', error: e);
      rethrow;
    }
  }
}
