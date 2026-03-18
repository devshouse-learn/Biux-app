
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
      const AchievementEntity(id: 'km_10', title: 'achievement_first_pedals', description: 'achievement_first_pedals_desc', icon: '🚲', category: 'distance', targetValue: 10),
      const AchievementEntity(id: 'km_50', title: 'achievement_explorer', description: 'achievement_explorer_desc', icon: '🗺️', category: 'distance', targetValue: 50),
      const AchievementEntity(id: 'km_100', title: 'achievement_centenary', description: 'achievement_centenary_desc', icon: '💯', category: 'distance', targetValue: 100),
      const AchievementEntity(id: 'km_500', title: 'achievement_tireless', description: 'achievement_tireless_desc', icon: '⚡', category: 'distance', targetValue: 500),
      const AchievementEntity(id: 'km_1000', title: 'achievement_thousand_club', description: 'achievement_thousand_club_desc', icon: '🏆', category: 'distance', targetValue: 1000),
      const AchievementEntity(id: 'km_5000', title: 'achievement_ultra', description: 'achievement_ultra_desc', icon: '💎', category: 'distance', targetValue: 5000),

      // Rodadas
      const AchievementEntity(id: 'rides_1', title: 'achievement_first_ride', description: 'achievement_first_ride_desc', icon: '🎯', category: 'rides', targetValue: 1),
      const AchievementEntity(id: 'rides_10', title: 'achievement_regular', description: 'achievement_regular_desc', icon: '🔟', category: 'rides', targetValue: 10),
      const AchievementEntity(id: 'rides_50', title: 'achievement_veteran', description: 'achievement_veteran_desc', icon: '🎖️', category: 'rides', targetValue: 50),
      const AchievementEntity(id: 'rides_100', title: 'achievement_centurion', description: 'achievement_centurion_desc', icon: '👑', category: 'rides', targetValue: 100),

      // Velocidad
      const AchievementEntity(id: 'speed_30', title: 'achievement_sprinter', description: 'achievement_sprinter_desc', icon: '🚀', category: 'speed', targetValue: 30),
      const AchievementEntity(id: 'speed_40', title: 'achievement_lightning', description: 'achievement_lightning_desc', icon: '⚡', category: 'speed', targetValue: 40),
      const AchievementEntity(id: 'speed_50', title: 'achievement_supersonic', description: 'achievement_supersonic_desc', icon: '🌪️', category: 'speed', targetValue: 50),

      // Racha
      const AchievementEntity(id: 'streak_3', title: 'achievement_consistent', description: 'achievement_consistent_desc', icon: '🔥', category: 'streak', targetValue: 3),
      const AchievementEntity(id: 'streak_7', title: 'achievement_perfect_week', description: 'achievement_perfect_week_desc', icon: '📅', category: 'streak', targetValue: 7),
      const AchievementEntity(id: 'streak_30', title: 'achievement_machine', description: 'achievement_machine_desc', icon: '🤖', category: 'streak', targetValue: 30),

      // Social
      const AchievementEntity(id: 'group_1', title: 'achievement_social', description: 'achievement_social_desc', icon: '👥', category: 'social', targetValue: 1),
      const AchievementEntity(id: 'group_5', title: 'achievement_popular', description: 'achievement_popular_desc', icon: '🌟', category: 'social', targetValue: 5),

      // Especiales
      const AchievementEntity(id: 'night_ride', title: 'achievement_nocturnal', description: 'achievement_nocturnal_desc', icon: '🌙', category: 'special', targetValue: 1),
      const AchievementEntity(id: 'rain_ride', title: 'achievement_rain_or_shine', description: 'achievement_rain_or_shine_desc', icon: '��️', category: 'special', targetValue: 1),
      const AchievementEntity(id: 'early_bird', title: 'achievement_early_bird', description: 'achievement_early_bird_desc', icon: '🌅', category: 'special', targetValue: 1),
    ];
  }
}
