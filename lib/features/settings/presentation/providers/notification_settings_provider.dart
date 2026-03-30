import 'package:flutter/material.dart';
import '../../domain/entities/notification_settings_entity.dart';
import '../../domain/repositories/notification_settings_repository.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  final NotificationSettingsRepository _repository;

  NotificationSettingsEntity? _settings;
  bool _isLoading = false;
  String? _error;

  NotificationSettingsProvider(this._repository);

  // Getters
  NotificationSettingsEntity? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cargar configuración de notificaciones
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _repository.getSettings();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar configuración: $e';
      _settings = NotificationSettingsEntity.defaults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activar/desactivar todas las notificaciones push
  Future<void> togglePushNotifications(bool enabled) async {
    if (_settings == null) return;

    try {
      await _repository.togglePushNotifications(enabled);
      if (_settings == null) return;
    _settings = _settings!.copyWith(enablePushNotifications: enabled);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar configuración: $e';
      notifyListeners();
    }
  }

  /// Activar/desactivar notificaciones de likes
  Future<void> toggleLikes(bool enabled) async {
    await _toggleType('like', enabled, (s) => s.copyWith(enableLikes: enabled));
  }

  /// Activar/desactivar notificaciones de comentarios
  Future<void> toggleComments(bool enabled) async {
    await _toggleType(
      'comment',
      enabled,
      (s) => s.copyWith(enableComments: enabled),
    );
  }

  /// Activar/desactivar notificaciones de seguidores
  Future<void> toggleFollows(bool enabled) async {
    await _toggleType(
      'follow',
      enabled,
      (s) => s.copyWith(enableFollows: enabled),
    );
  }

  /// Activar/desactivar notificaciones de invitaciones a rodadas
  Future<void> toggleRideInvitations(bool enabled) async {
    await _toggleType(
      'ride_invitation',
      enabled,
      (s) => s.copyWith(enableRideInvitations: enabled),
    );
  }

  /// Activar/desactivar notificaciones de invitaciones a grupos
  Future<void> toggleGroupInvitations(bool enabled) async {
    await _toggleType(
      'group_invitation',
      enabled,
      (s) => s.copyWith(enableGroupInvitations: enabled),
    );
  }

  /// Activar/desactivar notificaciones de historias
  Future<void> toggleStories(bool enabled) async {
    await _toggleType(
      'story',
      enabled,
      (s) => s.copyWith(enableStories: enabled),
    );
  }

  /// Activar/desactivar recordatorios de rodadas
  Future<void> toggleRideReminders(bool enabled) async {
    await _toggleType(
      'ride_reminder',
      enabled,
      (s) => s.copyWith(enableRideReminders: enabled),
    );
  }

  /// Activar/desactivar actualizaciones de grupos
  Future<void> toggleGroupUpdates(bool enabled) async {
    await _toggleType(
      'group_update',
      enabled,
      (s) => s.copyWith(enableGroupUpdates: enabled),
    );
  }

  /// Activar/desactivar notificaciones del sistema
  Future<void> toggleSystemNotifications(bool enabled) async {
    await _toggleType(
      'system',
      enabled,
      (s) => s.copyWith(enableSystemNotifications: enabled),
    );
  }

  /// Método auxiliar para cambiar un tipo de notificación
  Future<void> _toggleType(
    String type,
    bool enabled,
    NotificationSettingsEntity Function(NotificationSettingsEntity) updater,
  ) async {
    if (_settings == null) return;

    try {
      await _repository.toggleNotificationType(type, enabled);
      _settings = updater(_settings!);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar configuración: $e';
      notifyListeners();
    }
  }

  /// Resetear a configuración por defecto
  Future<void> resetToDefaults() async {
    try {
      await _repository.resetToDefaults();
      _settings = NotificationSettingsEntity.defaults();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al resetear configuración: $e';
      notifyListeners();
    }
  }

  /// Verificar si un tipo de notificación está habilitado
  bool isNotificationTypeEnabled(String type) {
    return _settings?.isNotificationTypeEnabled(type) ?? false;
  }
}
