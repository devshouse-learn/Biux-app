
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/achievements/domain/entities/achievement_entity.dart';
import 'package:biux/features/achievements/data/datasources/achievements_datasource.dart';
import 'package:biux/features/achievements/data/datasources/achievements_sync_service.dart';

class AchievementsProvider with ChangeNotifier {
  final AchievementsDatasource _datasource = AchievementsDatasource();


  List<AchievementEntity> _achievements = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _newlyUnlocked;
  List<AchievementEntity> _recentlyUnlocked = [];

  List<AchievementEntity> get achievements => _achievements;
  List<AchievementEntity> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  int get unlockedCount => unlockedAchievements.length;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get newlyUnlocked => _newlyUnlocked;
  List<AchievementEntity> get recentlyUnlocked => _recentlyUnlocked;

  void clearNewlyUnlocked() {
    _newlyUnlocked = null;
    _recentlyUnlocked = [];
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

  /// Llamar al terminar una rodada para actualizar logros automáticamente
  Future<void> onRideCompleted({
    required String userId,
    required double km,
    required double maxSpeedKmh,
    required int durationSec,
    required double totalKmAccumulated,
    required int totalRides,
    required int streakDays,
  }) async {
    if (_achievements.isEmpty) await loadAchievements(userId);

    _recentlyUnlocked = [];

    for (int i = 0; i < _achievements.length; i++) {
      final a = _achievements[i];
      if (a.isUnlocked) continue;

      double newValue = a.currentValue;

      switch (a.category) {
        case 'distance':
          newValue = totalKmAccumulated;
          break;
        case 'rides':
          newValue = totalRides.toDouble();
          break;
        case 'speed':
          if (maxSpeedKmh > a.currentValue) newValue = maxSpeedKmh;
          break;
        case 'streak':
          newValue = streakDays.toDouble();
          break;
        default:
          break;
      }

      if (newValue != a.currentValue) {
        _achievements[i] = a.copyWith(currentValue: newValue);
      }

      // Verificar si se desbloquea
      if (_achievements[i].currentValue >= _achievements[i].targetValue &&
          !_achievements[i].isUnlocked) {
        _achievements[i] = _achievements[i].copyWith(
          unlockedAt: DateTime.now(),
        );
        _recentlyUnlocked.add(_achievements[i]);
        _newlyUnlocked = _achievements[i].id;
      }
    }

    // Persistir en Firestore
    if (_recentlyUnlocked.isNotEmpty || true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final ref = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('achievements');

        for (final a in _achievements) {
          batch.set(ref.doc(a.id), {
            'currentValue': a.currentValue,
            'unlockedAt': a.unlockedAt,
          }, SetOptions(merge: true));
        }
        await batch.commit();
      } catch (e) {
        debugPrint('Error saving achievements: \$e');
      }
    }

    notifyListeners();
  }

  Future<void> _syncIfNeeded(String userId) async {
    _isSyncing = true;
    notifyListeners();
    try {
      await AchievementsSyncService.syncIfNeeded(userId);
    } catch (e) {
      debugPrint('Sync error: $e');
    }
    _isSyncing = false;
    notifyListeners();
  }
  /// Fuerza sincronización completa — llamado desde UI
  Future<void> forceSync(String userId) async {
    _isSyncing = true;
    notifyListeners();
    try {
      await AchievementsSyncService.fullSync(userId);
      await loadAchievements(userId);
    } catch (e) {
      debugPrint('forceSync error: $e');
    }
    _isSyncing = false;
    notifyListeners();
  }

  /// Callback para mostrar overlay cuando se desbloquea un logro
  Function(String achievementId)? onAchievementUnlocked;

  /// Verificar y desbloquear logros según estadísticas
  Future<void> checkAndUnlock({
    required String userId,
    required Map<String, dynamic> stats,
  }) async {
    for (final a in _achievements.where((x) => !x.isUnlocked)) {
      final progress = stats[a.id] as double? ?? 0;
      if (progress >= a.targetValue) {
        await _datasource.unlockAchievement(userId, a.id);
        _newlyUnlocked = a.id;
        _recentlyUnlocked = [..._recentlyUnlocked, a];
        onAchievementUnlocked?.call(a.id);
        notifyListeners();
      }
    }
  }

}