import '../entities/notification_settings_entity.dart';

/// Repositorio para gestionar las preferencias de notificaciones
abstract class NotificationSettingsRepository {
  /// Obtener las preferencias de notificaciones del usuario actual
  Future<NotificationSettingsEntity> getSettings();

  /// Actualizar las preferencias de notificaciones
  Future<void> updateSettings(NotificationSettingsEntity settings);

  /// Activar/desactivar todas las notificaciones push
  Future<void> togglePushNotifications(bool enabled);

  /// Activar/desactivar un tipo específico de notificación
  Future<void> toggleNotificationType(String type, bool enabled);

  /// Resetear a configuración por defecto
  Future<void> resetToDefaults();
}
