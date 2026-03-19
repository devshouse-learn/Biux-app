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
  final String level; // novato, intermedio, avanzado, experto, leyenda
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
      case 'intermedio':
        return '⚡';
      case 'avanzado':
        return '🔥';
      case 'experto':
        return '💎';
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
      case 'intermedio':
        return 'level_intermediate';
      case 'avanzado':
        return 'level_advanced';
      case 'experto':
        return 'level_expert';
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
    if (totalKm >= 5000) return 'experto';
    if (totalKm >= 1000) return 'avanzado';
    if (totalKm >= 200) return 'intermedio';
    return 'novato';
  }

  double get progressToNextLevel {
    switch (level) {
      case 'novato':
        return (totalKm / 200).clamp(0, 1);
      case 'intermedio':
        return ((totalKm - 200) / 800).clamp(0, 1);
      case 'avanzado':
        return ((totalKm - 1000) / 4000).clamp(0, 1);
      case 'experto':
        return ((totalKm - 5000) / 5000).clamp(0, 1);
      default:
        return 1.0;
    }
  }

  String get nextLevelName {
    switch (level) {
      case 'novato':
        return 'Intermedio';
      case 'intermedio':
        return 'Avanzado';
      case 'avanzado':
        return 'Experto';
      case 'experto':
        return 'Leyenda';
      default:
        return 'Max';
    }
  }

  double get kmToNextLevel {
    switch (level) {
      case 'novato':
        return 200 - totalKm;
      case 'intermedio':
        return 1000 - totalKm;
      case 'avanzado':
        return 5000 - totalKm;
      case 'experto':
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
