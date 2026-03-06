
class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category; // distance, rides, speed, social, streak, special
  final double targetValue;
  final double currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0, 1) : 0;

  static List<AchievementEntity> defaultAchievements() {
    return [
      // Distancia
      const AchievementEntity(id: 'km_10', title: 'Primeros Pedales', description: 'Recorre 10 km', icon: '🚲', category: 'distance', targetValue: 10),
      const AchievementEntity(id: 'km_50', title: 'Explorador', description: 'Recorre 50 km', icon: '🗺️', category: 'distance', targetValue: 50),
      const AchievementEntity(id: 'km_100', title: 'Centenario', description: 'Recorre 100 km', icon: '💯', category: 'distance', targetValue: 100),
      const AchievementEntity(id: 'km_500', title: 'Rodador Incansable', description: 'Recorre 500 km', icon: '⚡', category: 'distance', targetValue: 500),
      const AchievementEntity(id: 'km_1000', title: 'Mil Km Club', description: 'Recorre 1,000 km', icon: '🏆', category: 'distance', targetValue: 1000),
      const AchievementEntity(id: 'km_5000', title: 'Ultra Ciclista', description: 'Recorre 5,000 km', icon: '💎', category: 'distance', targetValue: 5000),

      // Rodadas
      const AchievementEntity(id: 'rides_1', title: 'Primera Rodada', description: 'Completa tu primera rodada', icon: '🎯', category: 'rides', targetValue: 1),
      const AchievementEntity(id: 'rides_10', title: 'Habitual', description: 'Completa 10 rodadas', icon: '🔟', category: 'rides', targetValue: 10),
      const AchievementEntity(id: 'rides_50', title: 'Veterano', description: 'Completa 50 rodadas', icon: '🎖️', category: 'rides', targetValue: 50),
      const AchievementEntity(id: 'rides_100', title: 'Centurion', description: 'Completa 100 rodadas', icon: '👑', category: 'rides', targetValue: 100),

      // Velocidad
      const AchievementEntity(id: 'speed_30', title: 'Velocista', description: 'Alcanza 30 km/h', icon: '🚀', category: 'speed', targetValue: 30),
      const AchievementEntity(id: 'speed_40', title: 'Rayo', description: 'Alcanza 40 km/h', icon: '⚡', category: 'speed', targetValue: 40),
      const AchievementEntity(id: 'speed_50', title: 'Supersonica', description: 'Alcanza 50 km/h', icon: '🌪️', category: 'speed', targetValue: 50),

      // Racha
      const AchievementEntity(id: 'streak_3', title: 'Constante', description: '3 dias seguidos pedaleando', icon: '🔥', category: 'streak', targetValue: 3),
      const AchievementEntity(id: 'streak_7', title: 'Semana Perfecta', description: '7 dias seguidos', icon: '📅', category: 'streak', targetValue: 7),
      const AchievementEntity(id: 'streak_30', title: 'Maquina', description: '30 dias seguidos', icon: '🤖', category: 'streak', targetValue: 30),

      // Social
      const AchievementEntity(id: 'group_1', title: 'Social', description: 'Unete a un grupo', icon: '👥', category: 'social', targetValue: 1),
      const AchievementEntity(id: 'group_5', title: 'Popular', description: 'Unete a 5 grupos', icon: '🌟', category: 'social', targetValue: 5),

      // Especiales
      const AchievementEntity(id: 'night_ride', title: 'Nocturno', description: 'Completa una rodada nocturna', icon: '🌙', category: 'special', targetValue: 1),
      const AchievementEntity(id: 'rain_ride', title: 'Lluvia o Sol', description: 'Pedalea bajo la lluvia', icon: '��️', category: 'special', targetValue: 1),
      const AchievementEntity(id: 'early_bird', title: 'Madrugador', description: 'Rodada antes de las 6am', icon: '🌅', category: 'special', targetValue: 1),
    ];
  }
}
