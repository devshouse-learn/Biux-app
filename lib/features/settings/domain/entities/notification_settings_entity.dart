/// Entidad que representa las preferencias de notificaciones del usuario
class NotificationSettingsEntity {
  final bool enablePushNotifications;
  final bool enableLikes;
  final bool enableComments;
  final bool enableFollows;
  final bool enableRideInvitations;
  final bool enableGroupInvitations;
  final bool enableStories;
  final bool enableRideReminders;
  final bool enableGroupUpdates;
  final bool enableSystemNotifications;

  NotificationSettingsEntity({
    required this.enablePushNotifications,
    required this.enableLikes,
    required this.enableComments,
    required this.enableFollows,
    required this.enableRideInvitations,
    required this.enableGroupInvitations,
    required this.enableStories,
    required this.enableRideReminders,
    required this.enableGroupUpdates,
    required this.enableSystemNotifications,
  });

  /// Configuración por defecto (todo activado)
  factory NotificationSettingsEntity.defaults() {
    return NotificationSettingsEntity(
      enablePushNotifications: true,
      enableLikes: true,
      enableComments: true,
      enableFollows: true,
      enableRideInvitations: true,
      enableGroupInvitations: true,
      enableStories: true,
      enableRideReminders: true,
      enableGroupUpdates: true,
      enableSystemNotifications: true,
    );
  }

  /// Copiar con cambios
  NotificationSettingsEntity copyWith({
    bool? enablePushNotifications,
    bool? enableLikes,
    bool? enableComments,
    bool? enableFollows,
    bool? enableRideInvitations,
    bool? enableGroupInvitations,
    bool? enableStories,
    bool? enableRideReminders,
    bool? enableGroupUpdates,
    bool? enableSystemNotifications,
  }) {
    return NotificationSettingsEntity(
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableLikes: enableLikes ?? this.enableLikes,
      enableComments: enableComments ?? this.enableComments,
      enableFollows: enableFollows ?? this.enableFollows,
      enableRideInvitations:
          enableRideInvitations ?? this.enableRideInvitations,
      enableGroupInvitations:
          enableGroupInvitations ?? this.enableGroupInvitations,
      enableStories: enableStories ?? this.enableStories,
      enableRideReminders: enableRideReminders ?? this.enableRideReminders,
      enableGroupUpdates: enableGroupUpdates ?? this.enableGroupUpdates,
      enableSystemNotifications:
          enableSystemNotifications ?? this.enableSystemNotifications,
    );
  }

  /// Verificar si un tipo de notificación está habilitado
  bool isNotificationTypeEnabled(String type) {
    if (!enablePushNotifications) return false;

    switch (type) {
      case 'like':
        return enableLikes;
      case 'comment':
        return enableComments;
      case 'follow':
        return enableFollows;
      case 'ride_invitation':
        return enableRideInvitations;
      case 'group_invitation':
        return enableGroupInvitations;
      case 'story':
        return enableStories;
      case 'ride_reminder':
        return enableRideReminders;
      case 'group_update':
        return enableGroupUpdates;
      case 'system':
        return enableSystemNotifications;
      default:
        return false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableLikes': enableLikes,
      'enableComments': enableComments,
      'enableFollows': enableFollows,
      'enableRideInvitations': enableRideInvitations,
      'enableGroupInvitations': enableGroupInvitations,
      'enableStories': enableStories,
      'enableRideReminders': enableRideReminders,
      'enableGroupUpdates': enableGroupUpdates,
      'enableSystemNotifications': enableSystemNotifications,
    };
  }

  factory NotificationSettingsEntity.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsEntity(
      enablePushNotifications: map['enablePushNotifications'] ?? true,
      enableLikes: map['enableLikes'] ?? true,
      enableComments: map['enableComments'] ?? true,
      enableFollows: map['enableFollows'] ?? true,
      enableRideInvitations: map['enableRideInvitations'] ?? true,
      enableGroupInvitations: map['enableGroupInvitations'] ?? true,
      enableStories: map['enableStories'] ?? true,
      enableRideReminders: map['enableRideReminders'] ?? true,
      enableGroupUpdates: map['enableGroupUpdates'] ?? true,
      enableSystemNotifications: map['enableSystemNotifications'] ?? true,
    );
  }
}
