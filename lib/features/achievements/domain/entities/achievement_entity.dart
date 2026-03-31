/// Un nivel individual dentro de un logro (Bronce, Plata, Oro, Platino, Diamante)
class AchievementLevel {
  final String icon;
  final double targetValue;

  const AchievementLevel({required this.icon, required this.targetValue});
}

class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final String category;

  /// Lista de niveles (5 para categorias de cadena, 1 para especiales)
  final List<AchievementLevel> levels;

  final double currentValue;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.levels,
    this.currentValue = 0,
    this.unlockedAt,
  });

  /// Indice del nivel mas alto completado (-1 si ninguno)
  int get currentLevelIndex {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (currentValue >= levels[i].targetValue) return i;
    }
    return -1;
  }

  /// Verdadero cuando TODOS los niveles estan completos
  bool get isUnlocked => currentValue >= levels.last.targetValue;

  /// Icono del nivel actual (o del primero si ninguno completado)
  String get icon =>
      levels[currentLevelIndex >= 0 ? currentLevelIndex : 0].icon;

  /// Objetivo del SIGUIENTE nivel (o del ultimo si todos completos)
  double get nextLevelTarget {
    final next = currentLevelIndex + 1;
    return next < levels.length
        ? levels[next].targetValue
        : levels.last.targetValue;
  }

  /// Progreso hacia el siguiente nivel
  double get progress => nextLevelTarget > 0
      ? (currentValue / nextLevelTarget).clamp(0.0, 1.0)
      : 0.0;

  /// Alias para compatibilidad con UI existente
  double get targetValue => nextLevelTarget;

  AchievementEntity copyWith({double? currentValue, DateTime? unlockedAt}) {
    return AchievementEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      levels: levels,
      currentValue: currentValue ?? this.currentValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<AchievementEntity> defaultAchievements() {
    return [
      // ===================== DISTANCIA =====================
      const AchievementEntity(
        id: 'dist_explorer',
        title: 'achievement_dist_explorer',
        description: 'achievement_dist_explorer_desc',
        category: 'distance',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 10),
          AchievementLevel(icon: '🥈', targetValue: 30),
          AchievementLevel(icon: '🥇', targetValue: 60),
          AchievementLevel(icon: '💎', targetValue: 100),
          AchievementLevel(icon: '👑', targetValue: 200),
        ],
      ),
      const AchievementEntity(
        id: 'dist_traveler',
        title: 'achievement_dist_traveler',
        description: 'achievement_dist_traveler_desc',
        category: 'distance',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 250),
          AchievementLevel(icon: '🥈', targetValue: 400),
          AchievementLevel(icon: '🥇', targetValue: 600),
          AchievementLevel(icon: '💎', targetValue: 800),
          AchievementLevel(icon: '👑', targetValue: 1000),
        ],
      ),
      const AchievementEntity(
        id: 'dist_runner',
        title: 'achievement_dist_runner',
        description: 'achievement_dist_runner_desc',
        category: 'distance',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 1200),
          AchievementLevel(icon: '🥈', targetValue: 1500),
          AchievementLevel(icon: '🥇', targetValue: 2000),
          AchievementLevel(icon: '💎', targetValue: 3000),
          AchievementLevel(icon: '👑', targetValue: 5000),
        ],
      ),
      const AchievementEntity(
        id: 'dist_ultra',
        title: 'achievement_dist_ultra',
        description: 'achievement_dist_ultra_desc',
        category: 'distance',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 6000),
          AchievementLevel(icon: '🥈', targetValue: 7500),
          AchievementLevel(icon: '🥇', targetValue: 10000),
          AchievementLevel(icon: '💎', targetValue: 15000),
          AchievementLevel(icon: '👑', targetValue: 20000),
        ],
      ),
      const AchievementEntity(
        id: 'dist_legend',
        title: 'achievement_dist_legend',
        description: 'achievement_dist_legend_desc',
        category: 'distance',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 25000),
          AchievementLevel(icon: '🥈', targetValue: 35000),
          AchievementLevel(icon: '🥇', targetValue: 50000),
          AchievementLevel(icon: '💎', targetValue: 75000),
          AchievementLevel(icon: '👑', targetValue: 100000),
        ],
      ),

      // ===================== RODADAS =====================
      const AchievementEntity(
        id: 'rides_starter',
        title: 'achievement_rides_starter',
        description: 'achievement_rides_starter_desc',
        category: 'rides',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 1),
          AchievementLevel(icon: '🥈', targetValue: 3),
          AchievementLevel(icon: '🥇', targetValue: 5),
          AchievementLevel(icon: '💎', targetValue: 8),
          AchievementLevel(icon: '👑', targetValue: 12),
        ],
      ),
      const AchievementEntity(
        id: 'rides_regular',
        title: 'achievement_rides_regular',
        description: 'achievement_rides_regular_desc',
        category: 'rides',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 15),
          AchievementLevel(icon: '🥈', targetValue: 22),
          AchievementLevel(icon: '🥇', targetValue: 32),
          AchievementLevel(icon: '💎', targetValue: 44),
          AchievementLevel(icon: '👑', targetValue: 58),
        ],
      ),
      const AchievementEntity(
        id: 'rides_veteran',
        title: 'achievement_rides_veteran',
        description: 'achievement_rides_veteran_desc',
        category: 'rides',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 60),
          AchievementLevel(icon: '🥈', targetValue: 75),
          AchievementLevel(icon: '🥇', targetValue: 100),
          AchievementLevel(icon: '💎', targetValue: 125),
          AchievementLevel(icon: '👑', targetValue: 150),
        ],
      ),
      const AchievementEntity(
        id: 'rides_master',
        title: 'achievement_rides_master',
        description: 'achievement_rides_master_desc',
        category: 'rides',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 175),
          AchievementLevel(icon: '🥈', targetValue: 200),
          AchievementLevel(icon: '🥇', targetValue: 250),
          AchievementLevel(icon: '💎', targetValue: 300),
          AchievementLevel(icon: '👑', targetValue: 400),
        ],
      ),
      const AchievementEntity(
        id: 'rides_legend',
        title: 'achievement_rides_legend',
        description: 'achievement_rides_legend_desc',
        category: 'rides',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 500),
          AchievementLevel(icon: '🥈', targetValue: 600),
          AchievementLevel(icon: '🥇', targetValue: 750),
          AchievementLevel(icon: '💎', targetValue: 900),
          AchievementLevel(icon: '👑', targetValue: 1000),
        ],
      ),

      // ===================== VELOCIDAD =====================
      const AchievementEntity(
        id: 'speed_cruiser',
        title: 'achievement_speed_cruiser',
        description: 'achievement_speed_cruiser_desc',
        category: 'speed',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 20),
          AchievementLevel(icon: '🥈', targetValue: 23),
          AchievementLevel(icon: '🥇', targetValue: 25),
          AchievementLevel(icon: '💎', targetValue: 28),
          AchievementLevel(icon: '👑', targetValue: 30),
        ],
      ),
      const AchievementEntity(
        id: 'speed_sprinter',
        title: 'achievement_speed_sprinter',
        description: 'achievement_speed_sprinter_desc',
        category: 'speed',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 31),
          AchievementLevel(icon: '🥈', targetValue: 33),
          AchievementLevel(icon: '🥇', targetValue: 35),
          AchievementLevel(icon: '💎', targetValue: 37),
          AchievementLevel(icon: '👑', targetValue: 40),
        ],
      ),
      const AchievementEntity(
        id: 'speed_racer',
        title: 'achievement_speed_racer',
        description: 'achievement_speed_racer_desc',
        category: 'speed',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 41),
          AchievementLevel(icon: '🥈', targetValue: 43),
          AchievementLevel(icon: '🥇', targetValue: 45),
          AchievementLevel(icon: '💎', targetValue: 47),
          AchievementLevel(icon: '👑', targetValue: 50),
        ],
      ),
      const AchievementEntity(
        id: 'speed_rocket',
        title: 'achievement_speed_rocket',
        description: 'achievement_speed_rocket_desc',
        category: 'speed',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 52),
          AchievementLevel(icon: '🥈', targetValue: 55),
          AchievementLevel(icon: '🥇', targetValue: 58),
          AchievementLevel(icon: '💎', targetValue: 60),
          AchievementLevel(icon: '👑', targetValue: 65),
        ],
      ),
      const AchievementEntity(
        id: 'speed_sonic',
        title: 'achievement_speed_sonic',
        description: 'achievement_speed_sonic_desc',
        category: 'speed',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 68),
          AchievementLevel(icon: '🥈', targetValue: 72),
          AchievementLevel(icon: '🥇', targetValue: 77),
          AchievementLevel(icon: '💎', targetValue: 83),
          AchievementLevel(icon: '👑', targetValue: 90),
        ],
      ),

      // ===================== RACHA =====================
      const AchievementEntity(
        id: 'streak_init',
        title: 'achievement_streak_init',
        description: 'achievement_streak_init_desc',
        category: 'streak',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 3),
          AchievementLevel(icon: '🥈', targetValue: 5),
          AchievementLevel(icon: '🥇', targetValue: 7),
          AchievementLevel(icon: '💎', targetValue: 10),
          AchievementLevel(icon: '👑', targetValue: 14),
        ],
      ),
      const AchievementEntity(
        id: 'streak_habit',
        title: 'achievement_streak_habit',
        description: 'achievement_streak_habit_desc',
        category: 'streak',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 17),
          AchievementLevel(icon: '🥈', targetValue: 21),
          AchievementLevel(icon: '🥇', targetValue: 25),
          AchievementLevel(icon: '💎', targetValue: 30),
          AchievementLevel(icon: '👑', targetValue: 35),
        ],
      ),
      const AchievementEntity(
        id: 'streak_machine',
        title: 'achievement_streak_machine',
        description: 'achievement_streak_machine_desc',
        category: 'streak',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 40),
          AchievementLevel(icon: '🥈', targetValue: 45),
          AchievementLevel(icon: '🥇', targetValue: 50),
          AchievementLevel(icon: '💎', targetValue: 60),
          AchievementLevel(icon: '👑', targetValue: 75),
        ],
      ),
      const AchievementEntity(
        id: 'streak_iron',
        title: 'achievement_streak_iron',
        description: 'achievement_streak_iron_desc',
        category: 'streak',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 80),
          AchievementLevel(icon: '🥈', targetValue: 90),
          AchievementLevel(icon: '🥇', targetValue: 100),
          AchievementLevel(icon: '💎', targetValue: 120),
          AchievementLevel(icon: '👑', targetValue: 150),
        ],
      ),
      const AchievementEntity(
        id: 'streak_legend',
        title: 'achievement_streak_legend',
        description: 'achievement_streak_legend_desc',
        category: 'streak',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 180),
          AchievementLevel(icon: '🥈', targetValue: 200),
          AchievementLevel(icon: '🥇', targetValue: 250),
          AchievementLevel(icon: '💎', targetValue: 300),
          AchievementLevel(icon: '👑', targetValue: 365),
        ],
      ),

      // ===================== SOCIAL =====================
      const AchievementEntity(
        id: 'social_member',
        title: 'achievement_social_member',
        description: 'achievement_social_member_desc',
        category: 'social',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 1),
          AchievementLevel(icon: '🥈', targetValue: 2),
          AchievementLevel(icon: '🥇', targetValue: 4),
          AchievementLevel(icon: '💎', targetValue: 7),
          AchievementLevel(icon: '👑', targetValue: 10),
        ],
      ),
      const AchievementEntity(
        id: 'social_popular',
        title: 'achievement_social_popular',
        description: 'achievement_social_popular_desc',
        category: 'social',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 12),
          AchievementLevel(icon: '🥈', targetValue: 16),
          AchievementLevel(icon: '🥇', targetValue: 22),
          AchievementLevel(icon: '💎', targetValue: 30),
          AchievementLevel(icon: '👑', targetValue: 40),
        ],
      ),
      const AchievementEntity(
        id: 'social_connector',
        title: 'achievement_social_connector',
        description: 'achievement_social_connector_desc',
        category: 'social',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 45),
          AchievementLevel(icon: '🥈', targetValue: 58),
          AchievementLevel(icon: '🥇', targetValue: 75),
          AchievementLevel(icon: '💎', targetValue: 95),
          AchievementLevel(icon: '👑', targetValue: 120),
        ],
      ),
      const AchievementEntity(
        id: 'social_networker',
        title: 'achievement_social_networker',
        description: 'achievement_social_networker_desc',
        category: 'social',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 135),
          AchievementLevel(icon: '🥈', targetValue: 160),
          AchievementLevel(icon: '🥇', targetValue: 200),
          AchievementLevel(icon: '💎', targetValue: 250),
          AchievementLevel(icon: '👑', targetValue: 320),
        ],
      ),
      const AchievementEntity(
        id: 'social_ambassador',
        title: 'achievement_social_ambassador',
        description: 'achievement_social_ambassador_desc',
        category: 'social',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 350),
          AchievementLevel(icon: '🥈', targetValue: 420),
          AchievementLevel(icon: '🥇', targetValue: 510),
          AchievementLevel(icon: '💎', targetValue: 620),
          AchievementLevel(icon: '👑', targetValue: 750),
        ],
      ),

      // ===================== AVENTURA =====================
      const AchievementEntity(
        id: 'aventura_start',
        title: 'achievement_aventura_start',
        description: 'achievement_aventura_start_desc',
        category: 'aventura',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 10),
          AchievementLevel(icon: '🥈', targetValue: 20),
          AchievementLevel(icon: '🥇', targetValue: 32),
          AchievementLevel(icon: '💎', targetValue: 45),
          AchievementLevel(icon: '👑', targetValue: 60),
        ],
      ),
      const AchievementEntity(
        id: 'aventura_explorer',
        title: 'achievement_aventura_explorer',
        description: 'achievement_aventura_explorer_desc',
        category: 'aventura',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 70),
          AchievementLevel(icon: '🥈', targetValue: 90),
          AchievementLevel(icon: '🥇', targetValue: 115),
          AchievementLevel(icon: '💎', targetValue: 145),
          AchievementLevel(icon: '👑', targetValue: 180),
        ],
      ),
      const AchievementEntity(
        id: 'aventura_fondo',
        title: 'achievement_aventura_fondo',
        description: 'achievement_aventura_fondo_desc',
        category: 'aventura',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 200),
          AchievementLevel(icon: '🥈', targetValue: 248),
          AchievementLevel(icon: '🥇', targetValue: 305),
          AchievementLevel(icon: '💎', targetValue: 370),
          AchievementLevel(icon: '👑', targetValue: 450),
        ],
      ),
      const AchievementEntity(
        id: 'aventura_ultra',
        title: 'achievement_aventura_ultra',
        description: 'achievement_aventura_ultra_desc',
        category: 'aventura',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 480),
          AchievementLevel(icon: '🥈', targetValue: 560),
          AchievementLevel(icon: '🥇', targetValue: 650),
          AchievementLevel(icon: '💎', targetValue: 750),
          AchievementLevel(icon: '👑', targetValue: 870),
        ],
      ),
      const AchievementEntity(
        id: 'aventura_expedition',
        title: 'achievement_aventura_expedition',
        description: 'achievement_aventura_expedition_desc',
        category: 'aventura',
        levels: [
          AchievementLevel(icon: '🥉', targetValue: 920),
          AchievementLevel(icon: '🥈', targetValue: 1020),
          AchievementLevel(icon: '🥇', targetValue: 1140),
          AchievementLevel(icon: '💎', targetValue: 1280),
          AchievementLevel(icon: '👑', targetValue: 1440),
        ],
      ),

      // ===================== ESPECIALES =====================
      const AchievementEntity(
        id: 'night_ride',
        title: 'achievement_nocturnal',
        description: 'achievement_nocturnal_desc',
        category: 'special',
        levels: [AchievementLevel(icon: '🌙', targetValue: 1)],
      ),
      const AchievementEntity(
        id: 'early_bird',
        title: 'achievement_early_bird',
        description: 'achievement_early_bird_desc',
        category: 'special',
        levels: [AchievementLevel(icon: '🌅', targetValue: 1)],
      ),
      const AchievementEntity(
        id: 'weekend_warrior',
        title: 'achievement_weekend_warrior',
        description: 'achievement_weekend_warrior_desc',
        category: 'special',
        levels: [AchievementLevel(icon: '🏖️', targetValue: 1)],
      ),
      const AchievementEntity(
        id: 'evening_ride',
        title: 'achievement_evening_ride',
        description: 'achievement_evening_ride_desc',
        category: 'special',
        levels: [AchievementLevel(icon: '🌇', targetValue: 1)],
      ),
      const AchievementEntity(
        id: 'long_single',
        title: 'achievement_long_single',
        description: 'achievement_long_single_desc',
        category: 'special',
        levels: [AchievementLevel(icon: '💪', targetValue: 1)],
      ),
    ];
  }
}
