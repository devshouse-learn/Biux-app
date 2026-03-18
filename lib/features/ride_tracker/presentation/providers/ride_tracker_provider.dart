import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:biux/features/ride_tracker/domain/entities/ride_track_entity.dart';
import 'package:biux/features/ride_tracker/data/datasources/ride_tracker_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideTrackerProvider with ChangeNotifier {
  final _ds = RideTrackerDatasource();
  List<TrackPoint> _points = [];
  List<RideTrackEntity> _history = [];
  bool _isTracking = false;
  bool _isPaused = false;
  bool _isLoading = false;
  bool _isSaving = false;
  double _totalKm = 0;
  double _currentSpeed = 0;
  double _maxSpeed = 0;
  int _durationSec = 0;
  DateTime? _startTime;
  StreamSubscription<Position>? _posSub;
  Timer? _timer;

  List<TrackPoint> get points => _points;
  List<RideTrackEntity> get history => _history;
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  double get totalKm => _totalKm;
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;
  int get durationSec => _durationSec;
  int get calories => (_totalKm * 30).toInt();

  double get avgSpeed {
    if (_durationSec < 1 || _totalKm <= 0) return 0;
    final v = _totalKm / (_durationSec / 3600);
    return v.isFinite ? v : 0;
  }

  String get durationFormatted {
    final hh = _durationSec ~/ 3600;
    final mm = (_durationSec % 3600) ~/ 60;
    final ss = _durationSec % 60;
    return '${hh.toString().padLeft(2, "0")}:${mm.toString().padLeft(2, "0")}:${ss.toString().padLeft(2, "0")}';
  }

  /// Inicia tracking. Retorna null si OK, o String con error.
  Future<String?> startTracking() async {
    // Verificar permisos GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'ride_error_gps_disabled';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'ride_error_location_permission';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return 'ride_error_location_denied';
    }

    _points = [];
    _totalKm = 0;
    _currentSpeed = 0;
    _maxSpeed = 0;
    _durationSec = 0;
    _isTracking = true;
    _isPaused = false;
    _startTime = DateTime.now();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        _durationSec++;
        notifyListeners();
      }
    });

    _posSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 2,
          ),
        ).listen(
          (pos) {
            if (_isPaused) return;
            final pt = TrackPoint(
              lat: pos.latitude,
              lng: pos.longitude,
              elevation: pos.altitude,
              speed: pos.speed * 3.6,
              timestamp: DateTime.now(),
            );
            if (_points.isNotEmpty) {
              final last = _points.last;
              _totalKm += _calcDist(last.lat, last.lng, pt.lat, pt.lng);
            }
            _currentSpeed = pt.speed;
            if (pt.speed > _maxSpeed) _maxSpeed = pt.speed;
            _points.add(pt);
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error GPS stream: $e');
          },
        );

    return null;
  }

  void pauseTracking() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeTracking() {
    _isPaused = false;
    notifyListeners();
  }

  Future<bool> stopAndSave(String userId) async {
    _isSaving = true;
    _isTracking = false;
    _posSub?.cancel();
    _posSub = null;
    _timer?.cancel();
    _timer = null;
    notifyListeners();

    if (_points.length < 2 && _durationSec < 30) {
      _isSaving = false;
      _points = [];
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final savedPoints = List<TrackPoint>.from(_points);
    final savedKm = _totalKm;
    final savedAvg = avgSpeed;
    final savedMax = _maxSpeed;
    final savedDurSec = _durationSec;
    final savedDurMin = _durationSec ~/ 60;
    final savedCal = calories;
    final savedStart = _startTime;

    try {
      final trackId = await _ds.saveTrackFast(userId, {
        'totalKm': savedKm,
        'avgSpeed': savedAvg,
        'maxSpeed': savedMax,
        'durationMinutes': savedDurMin,
        'durationSeconds': savedDurSec,
        'calories': savedCal,
        'pointCount': savedPoints.length,
        'startTime': savedStart?.millisecondsSinceEpoch,
        'endTime': now.millisecondsSinceEpoch,
      });

      _history.insert(
        0,
        RideTrackEntity(
          id: trackId,
          userId: userId,
          points: [],
          totalKm: savedKm,
          avgSpeed: savedAvg,
          maxSpeed: savedMax,
          durationMinutes: savedDurMin,
          durationSeconds: savedDurSec,
          calories: savedCal,
          pointCount: savedPoints.length,
          startTime: savedStart ?? now,
          endTime: now,
        ),
      );

      _points = [];
      _isSaving = false;
      notifyListeners();

      _saveBackgroundData(userId, trackId, savedPoints, savedStart);
      return true;
    } catch (e) {
      debugPrint('Error guardando rodada: $e');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void _saveBackgroundData(
    String userId,
    String trackId,
    List<TrackPoint> savedPoints,
    DateTime? startTime,
  ) {
    Future(() async {
      try {
        if (savedPoints.isNotEmpty) {
          await _ds.saveTrackPoints(
            trackId,
            savedPoints.map((p) => p.toMap()).toList(),
          );
          debugPrint('[BG] Puntos GPS guardados: ${savedPoints.length}');
        }
      } catch (e) {
        debugPrint('[BG] Error guardando puntos: $e');
      }

      try {
        double accumKm = 0;
        double bestMax = 0;
        int totalRides = _history.length;
        int totalMin = 0;

        for (final r in _history) {
          accumKm += r.totalKm;
          totalMin += r.durationMinutes;
          if (r.maxSpeed > bestMax) bestMax = r.maxSpeed;
        }

        int streak = _calculateStreak();

        await FirebaseFirestore.instance
            .collection('user_stats')
            .doc(userId)
            .set({
              'totalKm': accumKm,
              'totalRides': totalRides,
              'maxSpeed': bestMax,
              'streak': streak,
              'lastRideDate': DateTime.now().millisecondsSinceEpoch,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        final avgSpeedGlobal = totalMin > 0 ? accumKm / (totalMin / 60) : 0.0;
        await FirebaseFirestore.instance
            .collection('cycling_stats')
            .doc(userId)
            .set({
              'userId': userId,
              'totalKm': accumKm,
              'totalRides': totalRides,
              'avgSpeed': avgSpeedGlobal.isFinite ? avgSpeedGlobal : 0,
              'maxSpeed': bestMax,
              'totalCalories': (accumKm * 30).toInt(),
              'totalMinutes': totalMin,
              'streak': streak,
              'level': _calculateLevel(accumKm),
              'lastRideDate': Timestamp.fromDate(DateTime.now()),
            }, SetOptions(merge: true));

        await _updateAchievements(
          userId,
          accumKm,
          totalRides,
          bestMax,
          streak,
          startTime,
        );
        debugPrint('[BG] Stats y logros actualizados');
      } catch (e) {
        debugPrint('[BG] Error actualizando stats: $e');
      }
    });
  }

  Future<void> _updateAchievements(
    String userId,
    double accumKm,
    int totalRides,
    double bestMax,
    int streak,
    DateTime? startTime,
  ) async {
    int groupCount = 0;
    try {
      final gs = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();
      groupCount = gs.docs.length;
    } catch (_) {}

    bool isNight = false;
    bool isEarly = false;
    if (startTime != null) {
      isNight = startTime.hour >= 20 || startTime.hour < 5;
      isEarly = startTime.hour < 6;
    }

    final ref = FirebaseFirestore.instance
        .collection('achievements')
        .doc(userId);
    final Map<String, dynamic> u = {};

    for (final t in [10.0, 50.0, 100.0, 500.0, 1000.0, 5000.0]) {
      u['km_${t.toInt()}'] = {
        'currentValue': accumKm,
        if (accumKm >= t) 'unlocked': true,
        if (accumKm >= t) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }
    for (final e in {
      1: 'rides_1',
      10: 'rides_10',
      50: 'rides_50',
      100: 'rides_100',
    }.entries) {
      u[e.value] = {
        'currentValue': totalRides,
        if (totalRides >= e.key) 'unlocked': true,
        if (totalRides >= e.key) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }
    for (final t in [30.0, 40.0, 50.0]) {
      u['speed_${t.toInt()}'] = {
        'currentValue': bestMax,
        if (bestMax >= t) 'unlocked': true,
        if (bestMax >= t) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }
    for (final e in {3: 'streak_3', 7: 'streak_7', 30: 'streak_30'}.entries) {
      u[e.value] = {
        'currentValue': streak,
        if (streak >= e.key) 'unlocked': true,
        if (streak >= e.key) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }
    for (final e in {1: 'group_1', 5: 'group_5'}.entries) {
      u[e.value] = {
        'currentValue': groupCount,
        if (groupCount >= e.key) 'unlocked': true,
        if (groupCount >= e.key) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }
    if (isNight)
      u['night_ride'] = {
        'currentValue': 1.0,
        'unlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
      };
    if (isEarly)
      u['early_bird'] = {
        'currentValue': 1.0,
        'unlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
      };

    await ref.set(u, SetOptions(merge: true));
  }

  String _calculateLevel(double km) {
    if (km >= 10000) return 'leyenda';
    if (km >= 5000) return 'experto';
    if (km >= 1000) return 'avanzado';
    if (km >= 200) return 'intermedio';
    return 'novato';
  }

  int _calculateStreak() {
    if (_history.isEmpty) return 1;
    final dates =
        _history
            .map(
              (r) => DateTime(
                r.startTime.year,
                r.startTime.month,
                r.startTime.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (!dates.contains(today)) dates.insert(0, today);
    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i].difference(dates[i + 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  void cancelTracking() {
    _isTracking = false;
    _posSub?.cancel();
    _posSub = null;
    _timer?.cancel();
    _timer = null;
    _points = [];
    notifyListeners();
  }

  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _ds.getUserTracks(userId);
      _history = _mapHistory(data);
    } catch (e) {
      debugPrint('Error loading history: $e');
      // Fallback sin orderBy (no requiere índice compuesto)
      try {
        final data = await _ds.getUserTracksSimple(userId);
        _history = _mapHistory(data);
        _history.sort((a, b) => b.startTime.compareTo(a.startTime));
      } catch (e2) {
        debugPrint('Error loading history (fallback): $e2');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  List<RideTrackEntity> _mapHistory(List<Map<String, dynamic>> data) {
    return data
        .map(
          (m) => RideTrackEntity(
            id: m['id'] ?? '',
            userId: m['userId'] ?? '',
            points: [],
            totalKm: (m['totalKm'] as num?)?.toDouble() ?? 0,
            avgSpeed: (m['avgSpeed'] as num?)?.toDouble() ?? 0,
            maxSpeed: (m['maxSpeed'] as num?)?.toDouble() ?? 0,
            durationMinutes: (m['durationMinutes'] as num?)?.toInt() ?? 0,
            durationSeconds: (m['durationSeconds'] as num?)?.toInt() ?? 0,
            calories: (m['calories'] as num?)?.toInt() ?? 0,
            pointCount: (m['pointCount'] as num?)?.toInt() ?? 0,
            startTime: DateTime.fromMillisecondsSinceEpoch(m['startTime'] ?? 0),
            endTime: DateTime.fromMillisecondsSinceEpoch(m['endTime'] ?? 0),
          ),
        )
        .toList();
  }

  Future<void> deleteRide(String trackId, String userId) async {
    try {
      await _ds.deleteTrack(trackId);
      _history.removeWhere((r) => r.id == trackId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting ride: $e');
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  double _calcDist(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double d) => d * pi / 180;
}
