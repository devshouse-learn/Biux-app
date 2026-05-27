import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

      // Verificar que todos los campos requeridos estÃ©n presentes y no estÃ©n vacÃ­os
      for (String field in _requiredFields) {
        final value = userData[field];
        if (value == null || (value is String && value.trim().isEmpty)) {
          debugPrint('âŒ Campo faltante o vacÃ­o: $field');
          return false;
        }
      }

      debugPrint('âœ… Perfil completo para usuario: $uid');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('âš ï¸ Error verificando perfil: $e');
      return false;
    }
  }

  /// Obtiene un resumen de quÃ© campos le faltan completar al usuario
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
    } on FirebaseException catch (e) {
      debugPrint('âš ï¸ Error obteniendo campos faltantes: $e');
      return _requiredFields;
    }
  }

  /// Obtiene un mensaje amigable de los campos faltantes
  static Future<String> getMissingFieldsMessage({String? userId}) async {
    final missingFields = await getMissingFields(userId: userId);
    if (missingFields.isEmpty) return '';

    // Translation keys â€“ the caller with BuildContext should use l.t() on each key
    const fieldLabelKeys = {
      'fullName': 'field_full_name',
      'username': 'field_username',
      'photoUrl': 'field_photo_url',
      'gender': 'field_gender',
      'dateBirth': 'field_birth_date',
    };

    final keys = missingFields.map((f) => fieldLabelKeys[f] ?? f).toList();
    return 'please_complete_fields:${keys.join(',')}';
  }
}

