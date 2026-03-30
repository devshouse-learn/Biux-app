import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/features/achievements/domain/entities/achievement_entity.dart';
import 'package:biux/features/achievements/data/datasources/achievements_datasource.dart';
import 'package:biux/features/achievements/data/datasources/achievements_sync_service.dart';

class AchievementsProvider with ChangeNotifier {
  final AchievementsDatasource _datasource = AchievementsDatasource();

  static const _lastSyncKey = 'achievements_last_sync';
  static const _syncIntervalDays = 7;

  List<AchievementEntity> _achievements = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _newlyUnlocked;

  List<AchievementEntity> get achievements => _achievements;
  List<AchievementEntity> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  int get unlockedCount => unlockedAchievements.length;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get newlyUnlocked => _newlyUnlocked;

  void clearNewlyUnlocked() {
    _newlyUnlocked = null;
    notifyListeners();
  }

  Future<void> loadAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _syncIfNeeded(userId);

      final data = await _datasource.getUserAchievements(userId);
      final defaults = AchievementEntity.defaultAchievements();

      _achievements = defaults.map((a) {
        final saved = data[a.id] as Map<String, dynamic>?;
        if (saved != null) {
          return a.copyWith(
            currentValue: (saved['currentValue'] as num?)?.toDouble() ?? 0,
            unlockedAt: saved['unlockedAt'] != null
                ? (saved['unlockedAt'] as dynamic).toDate()
                : null,
          );
        }
        return a;
      }).toList();
    } catch (e) {
      debugPrint('Error loading achievements: \$e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncIfNeeded(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final daysSinceSync = (now - lastSync) / (1000 * 60 * 60 * 24);

      if (daysSinceSync >= _syncIntervalDays) {
        _isSyncing = true;
        notifyListeners();

        debugPrint(
          '\ud83d\udd04 Logros: Sync semanal (ultima vez hace \${daysSinceSync.toInt()} dias)',
        );
        await AchievementsSyncService.fullSync(userId);
        await prefs.setInt(_lastSyncKey, now);
        debugPrint('\u2705 Logros: Sync semanal completada');

        _isSyncing = false;
      }
    } catch (e) {
      _isSyncing = false;
      debugPrint('\u274c Error en sync semanal: \$e');
    }
  }

  Future<void> forceSync(String userId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      await AchievementsSyncService.fullSync(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('\u2705 Logros: Sync forzada completada');
    } catch (e) {
      debugPrint('\u274c Error en sync forzada: \$e');
    }

    _isSyncing = false;
    await loadAchievements(userId);
  }

  Future<void> checkAndUpdateAchievements(
    String userId, {
    double? totalKm,
    int? totalRides,
    double? maxSpeed,
    int? streak,
    int? groupCount,
  }) async {
    for (final a in _achievements) {
      if (a.isUnlocked) continue;

      double newValue = a.currentValue;

      switch (a.category) {
        case 'distance':
          if (totalKm != null) newValue = totalKm;
          break;
        case 'rides':
          if (totalRides != null) newValue = totalRides.toDouble();
          break;
        case 'speed':
          if (maxSpeed != null) newValue = maxSpeed;
          break;
        case 'streak':
          if (streak != null) newValue = streak.toDouble();
          break;
        case 'social':
          if (groupCount != null) newValue = groupCount.toDouble();
          break;
      }

      if (newValue != a.currentValue) {
        await _datasource.updateProgress(userId, a.id, newValue);
      }

      if (newValue >= a.targetValue && !a.isUnlocked) {
        await _datasource.unlockAchievement(userId, a.id);
        _newlyUnlocked = a.title;
      }
    }

    await loadAchievements(userId);
  }
}
