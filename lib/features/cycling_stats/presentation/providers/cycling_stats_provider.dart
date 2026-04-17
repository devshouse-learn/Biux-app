import 'package:flutter/foundation.dart';
import 'package:biux/features/cycling_stats/domain/entities/cycling_stats_entity.dart';
import 'package:biux/features/cycling_stats/data/datasources/cycling_stats_datasource.dart';

class CyclingStatsProvider with ChangeNotifier {
  final CyclingStatsDatasource _datasource = CyclingStatsDatasource();

  CyclingStatsEntity? _stats;
  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> _friendsLeaderboard = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  DateTime? _lastUpdated;

  CyclingStatsEntity? get stats => _stats;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  List<Map<String, dynamic>> get friendsLeaderboard => _friendsLeaderboard;
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

  Future<void> loadFriendsLeaderboard(List<String> friendIds) async {
    try {
      _friendsLeaderboard = await _datasource.getLeaderboardForUsers(friendIds);
      notifyListeners();
    } catch (e) {
      _error = 'stats_error_leaderboard';
      notifyListeners();
    }
  }

  // Progreso semanal (Ãºltimas 8 semanas)
  List<Map<String, dynamic>> _weeklyProgress = [];
  List<Map<String, dynamic>> get weeklyProgress => _weeklyProgress;

  /// RÃ©cords personales
  Map<String, dynamic> get personalRecords {
    if (_stats == null) return {};
    return {
      'maxSpeed': _stats!.maxSpeed,
      'longestRide': _stats!.totalKm > 0 ? _stats!.totalKm : 0,
      'bestStreak': _stats!.streak,
      'totalCalories': _stats!.totalCalories,
    };
  }

  void computeWeeklyProgress(List<Map<String, dynamic>> rides) {
    final now = DateTime.now();
    final weeks = <String, double>{};

    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + i * 7));
      final key = "${weekStart.day}/${weekStart.month}";
      weeks[key] = 0;
    }

    for (final ride in rides) {
      try {
        final date = (ride["startTime"] as dynamic).toDate() as DateTime;
        final km = (ride["km"] as num?)?.toDouble() ?? 0;
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final key = "${weekStart.day}/${weekStart.month}";
        if (weeks.containsKey(key)) {
          weeks[key] = (weeks[key] ?? 0) + km;
        }
      } catch (_) {}
    }

    _weeklyProgress = weeks.entries
        .map((e) => {"week": e.key, "km": e.value})
        .toList();
    notifyListeners();
  }

  List<Map<String, dynamic>> _heatmapPoints = [];
  List<Map<String, dynamic>> get heatmapPoints => _heatmapPoints;

  Future<void> loadHeatmap(String userId) async {
    try {
      final tracks = await _datasource.getUserTracks(userId);
      _heatmapPoints = [];
      for (final track in tracks) {
        final points = List<Map<String, dynamic>>.from(track['points'] ?? []);
        _heatmapPoints.addAll(
          points.map((p) => {'lat': p['lat'], 'lng': p['lng'], 'weight': 1.0}),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando heatmap: $e');
    }
  }
}
