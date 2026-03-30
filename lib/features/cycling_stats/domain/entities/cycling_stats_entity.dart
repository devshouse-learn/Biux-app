class CyclingStatsEntity {
  final String userId;
  final double totalKm;
  final int totalRides;
  final double avgSpeed;
  final double maxSpeed;
  final int totalElevation;
  final int totalCalories;
  final int totalMinutes;
  final int streak; // Dias consecutivos
  final String
  level; // novato, aprendiz, intermedio, avanzado, experto, elite, maestro, leyenda
  final DateTime lastRideDate;
  final Map<String, double> monthlyKm; // "2026-03": 150.5

  const CyclingStatsEntity({
    required this.userId,
    this.totalKm = 0,
    this.totalRides = 0,
    this.avgSpeed = 0,
    this.maxSpeed = 0,
    this.totalElevation = 0,
    this.totalCalories = 0,
    this.totalMinutes = 0,
    this.streak = 0,
    this.level = 'novato',
    required this.lastRideDate,
    this.monthlyKm = const {},
  });

  String get levelEmoji {
    switch (level) {
      case 'novato':
        return '🌱';
      case 'aprendiz':
        return '🚲';
      case 'intermedio':
        return '⚡';
      case 'avanzado':
        return '🔥';
      case 'experto':
        return '💎';
      case 'elite':
        return '🏆';
      case 'maestro':
        return '⭐';
      case 'leyenda':
        return '👑';
      default:
        return '🌱';
    }
  }

  /// Returns a translation key for the current level name.
  /// UI should call l.t(stats.levelName) to display.
  String get levelName {
    switch (level) {
      case 'novato':
        return 'level_novice';
      case 'aprendiz':
        return 'level_apprentice';
      case 'intermedio':
        return 'level_intermediate';
      case 'avanzado':
        return 'level_advanced';
      case 'experto':
        return 'level_expert';
      case 'elite':
        return 'level_elite';
      case 'maestro':
        return 'level_master';
      case 'leyenda':
        return 'level_legend';
      default:
        return 'level_novice';
    }
  }

  String get formattedTime {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  static String calculateLevel(double totalKm) {
    if (totalKm >= 10000) return 'leyenda';
    if (totalKm >= 5000) return 'maestro';
    if (totalKm >= 2500) return 'elite';
    if (totalKm >= 1000) return 'experto';
    if (totalKm >= 500) return 'avanzado';
    if (totalKm >= 150) return 'intermedio';
    if (totalKm >= 50) return 'aprendiz';
    return 'novato';
  }

  double get progressToNextLevel {
    switch (level) {
      case 'novato':
        return (totalKm / 50).clamp(0, 1);
      case 'aprendiz':
        return ((totalKm - 50) / 100).clamp(0, 1);
      case 'intermedio':
        return ((totalKm - 150) / 350).clamp(0, 1);
      case 'avanzado':
        return ((totalKm - 500) / 500).clamp(0, 1);
      case 'experto':
        return ((totalKm - 1000) / 1500).clamp(0, 1);
      case 'elite':
        return ((totalKm - 2500) / 2500).clamp(0, 1);
      case 'maestro':
        return ((totalKm - 5000) / 5000).clamp(0, 1);
      default:
        return 1.0;
    }
  }

  String get nextLevelName {
    switch (level) {
      case 'novato':
        return 'Aprendiz';
      case 'aprendiz':
        return 'Intermedio';
      case 'intermedio':
        return 'Avanzado';
      case 'avanzado':
        return 'Experto';
      case 'experto':
        return 'Élite';
      case 'elite':
        return 'Maestro';
      case 'maestro':
        return 'Leyenda';
      default:
        return 'Max';
    }
  }

  double get kmToNextLevel {
    switch (level) {
      case 'novato':
        return 50 - totalKm;
      case 'aprendiz':
        return 150 - totalKm;
      case 'intermedio':
        return 500 - totalKm;
      case 'avanzado':
        return 1000 - totalKm;
      case 'experto':
        return 2500 - totalKm;
      case 'elite':
        return 5000 - totalKm;
      case 'maestro':
        return 10000 - totalKm;
      default:
        return 0;
    }
  }

  CyclingStatsEntity copyWith({
    String? userId,
    double? totalKm,
    int? totalRides,
    double? avgSpeed,
    double? maxSpeed,
    int? totalElevation,
    int? totalCalories,
    int? totalMinutes,
    int? streak,
    String? level,
    DateTime? lastRideDate,
    Map<String, double>? monthlyKm,
  }) {
    return CyclingStatsEntity(
      userId: userId ?? this.userId,
      totalKm: totalKm ?? this.totalKm,
      totalRides: totalRides ?? this.totalRides,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      totalElevation: totalElevation ?? this.totalElevation,
      totalCalories: totalCalories ?? this.totalCalories,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      streak: streak ?? this.streak,
      level: level ?? this.level,
      lastRideDate: lastRideDate ?? this.lastRideDate,
      monthlyKm: monthlyKm ?? this.monthlyKm,
    );
  }
}
