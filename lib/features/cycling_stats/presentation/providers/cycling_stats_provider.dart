import 'package:flutter/foundation.dart';
import 'package:biux/features/cycling_stats/domain/entities/cycling_stats_entity.dart';
import 'package:biux/features/cycling_stats/data/datasources/cycling_stats_datasource.dart';

class CyclingStatsProvider with ChangeNotifier {
  final CyclingStatsDatasource _datasource = CyclingStatsDatasource();

  CyclingStatsEntity? _stats;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  DateTime? _lastUpdated;

  CyclingStatsEntity? get stats => _stats;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  String get lastUpdatedLabel {
    if (_lastUpdated == null) return '';
    final now = DateTime.now();
    final diff = now.difference(_lastUpdated!);
    if (diff.inSeconds < 30) return 'stats_just_now';
    if (diff.inMinutes < 1) return 'stats_seconds_ago';
    if (diff.inMinutes < 60) return 'stats_minutes_ago';
    if (diff.inHours < 24) return 'stats_hours_ago';
    if (_lastUpdated == null) return 'Sin datos';
    return '${_lastUpdated!.day}/${_lastUpdated!.month}/${_lastUpdated!.year}';
  }

  Future<void> loadStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _datasource.getStats(userId);
      if (data != null) {
        _stats = CyclingStatsEntity(
          userId: data['userId'] ?? userId,
          totalKm: (data['totalKm'] as num?)?.toDouble() ?? 0,
          totalRides: (data['totalRides'] as num?)?.toInt() ?? 0,
          avgSpeed: (data['avgSpeed'] as num?)?.toDouble() ?? 0,
          maxSpeed: (data['maxSpeed'] as num?)?.toDouble() ?? 0,
          totalElevation: (data['totalElevation'] as num?)?.toInt() ?? 0,
          totalCalories: (data['totalCalories'] as num?)?.toInt() ?? 0,
          totalMinutes: (data['totalMinutes'] as num?)?.toInt() ?? 0,
          streak: (data['streak'] as num?)?.toInt() ?? 0,
          level: data['level'] ?? 'novato',
          lastRideDate: data['lastRideDate'] != null
              ? (data['lastRideDate']).toDate()
              : DateTime.now(),
          monthlyKm: Map<String, double>.from(
            (data['monthlyKm'] as Map?)?.map(
                  (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
                ) ??
                {},
          ),
        );
      } else {
        _stats = CyclingStatsEntity(
          userId: userId,
          lastRideDate: DateTime.now(),
        );
      }
      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = 'stats_error_load';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll(String userId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      await loadStats(userId);
      await loadLeaderboard();
      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = 'stats_error_refresh';
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> addRide({
    required String userId,
    required double km,
    required double avgSpeed,
    required double maxSpeed,
    required int elevation,
    required int minutes,
  }) async {
    try {
      await _datasource.addRideStats(
        userId,
        km: km,
        avgSpeed: avgSpeed,
        maxSpeed: maxSpeed,
        elevation: elevation,
        minutes: minutes,
      );
      await loadStats(userId);
    } catch (e) {
      _error = 'stats_error_add_ride';
      notifyListeners();
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      _leaderboard = await _datasource.getLeaderboard();
      notifyListeners();
    } catch (e) {
      _error = 'stats_error_leaderboard';
      notifyListeners();
    }
  }
}
