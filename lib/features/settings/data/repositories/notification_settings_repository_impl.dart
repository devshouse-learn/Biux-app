import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:biux/features/settings/domain/repositories/notification_settings_repository.dart';
import "package:flutter/foundation.dart";

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<NotificationSettingsEntity> getSettings() async {
    if (_userId == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists && doc.data() != null) {
        return NotificationSettingsEntity.fromMap(doc.data()!);
      } else {
        // Si no existe, crear con valores por defecto
        final defaults = NotificationSettingsEntity.defaults();
        await updateSettings(defaults);
        return defaults;
      }
    } catch (e) {
      debugPrint('Error al obtener configuración de notificaciones: $e');
      return NotificationSettingsEntity.defaults();
    }
  }

  @override
  Future<void> updateSettings(NotificationSettingsEntity settings) async {
    if (_userId == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('notifications')
          .set(settings.toMap(), SetOptions(merge: true));

      // También actualizar en el documento principal del usuario para fácil acceso del backend
      await _firestore.collection('users').doc(_userId).update({
        'notificationSettings': settings.toMap(),
      });
    } catch (e) {
      debugPrint('Error al actualizar configuración de notificaciones: $e');
      rethrow;
    }
  }

  @override
  Future<void> togglePushNotifications(bool enabled) async {
    final currentSettings = await getSettings();
    final newSettings = currentSettings.copyWith(
      enablePushNotifications: enabled,
    );
    await updateSettings(newSettings);
  }

  @override
  Future<void> toggleNotificationType(String type, bool enabled) async {
    final currentSettings = await getSettings();
    NotificationSettingsEntity newSettings;

    switch (type) {
      case 'like':
        newSettings = currentSettings.copyWith(enableLikes: enabled);
        break;
      case 'comment':
        newSettings = currentSettings.copyWith(enableComments: enabled);
        break;
      case 'follow':
        newSettings = currentSettings.copyWith(enableFollows: enabled);
        break;
      case 'ride_invitation':
        newSettings = currentSettings.copyWith(enableRideInvitations: enabled);
        break;
      case 'group_invitation':
        newSettings = currentSettings.copyWith(enableGroupInvitations: enabled);
        break;
      case 'story':
        newSettings = currentSettings.copyWith(enableStories: enabled);
        break;
      case 'ride_reminder':
        newSettings = currentSettings.copyWith(enableRideReminders: enabled);
        break;
      case 'group_update':
        newSettings = currentSettings.copyWith(enableGroupUpdates: enabled);
        break;
      case 'system':
        newSettings = currentSettings.copyWith(
          enableSystemNotifications: enabled,
        );
        break;
      default:
        return;
    }

    await updateSettings(newSettings);
  }

  @override
  Future<void> resetToDefaults() async {
    await updateSettings(NotificationSettingsEntity.defaults());
  }
}
