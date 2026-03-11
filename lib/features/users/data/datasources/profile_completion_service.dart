import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/foundation.dart";

/// Servicio centralizado para validar que un usuario ha completado su perfil
class ProfileCompletionService {
  static const List<String> _requiredFields = [
    'fullName',
    'username',
    'photoUrl',
    'gender',
    'dateBirth',
  ];

  /// Verifica si un usuario ha completado su perfil
  /// Retorna true si tiene todos los campos requeridos completados
  static Future<bool> hasCompletedProfile({String? userId}) async {
    try {
      final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() ?? {};

      // Verificar que todos los campos requeridos estén presentes y no estén vacíos
      for (String field in _requiredFields) {
        final value = userData[field];
        if (value == null || (value is String && value.trim().isEmpty)) {
          debugPrint('❌ Campo faltante o vacío: $field');
          return false;
        }
      }

      debugPrint('✅ Perfil completo para usuario: $uid');
      return true;
    } catch (e) {
      debugPrint('⚠️ Error verificando perfil: $e');
      return false;
    }
  }

  /// Obtiene un resumen de qué campos le faltan completar al usuario
  static Future<List<String>> getMissingFields({String? userId}) async {
    try {
      final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return _requiredFields;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) return _requiredFields;

      final userData = userDoc.data() ?? {};
      final missing = <String>[];

      for (String field in _requiredFields) {
        final value = userData[field];
        if (value == null || (value is String && value.trim().isEmpty)) {
          missing.add(field);
        }
      }

      return missing;
    } catch (e) {
      debugPrint('⚠️ Error obteniendo campos faltantes: $e');
      return _requiredFields;
    }
  }

  /// Obtiene un mensaje amigable de los campos faltantes
  static Future<String> getMissingFieldsMessage({String? userId}) async {
    final missingFields = await getMissingFields(userId: userId);
    if (missingFields.isEmpty) return '';

    final fieldLabels = {
      'fullName': 'nombre completo',
      'username': 'nombre de usuario',
      'photoUrl': 'foto de perfil',
      'gender': 'género',
      'dateBirth': 'fecha de nacimiento',
    };

    final labels = missingFields.map((f) => fieldLabels[f] ?? f).toList();
    return 'Por favor completa: ${labels.join(', ')}';
  }
}
