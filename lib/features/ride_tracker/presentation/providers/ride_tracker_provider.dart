import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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

  // Posición en vivo (antes y durante el tracking)
  LatLng? _livePosition;
  StreamSubscription<Position>? _livePosSub;

  // Ruta planeada (origen→destino)
  List<LatLng> _plannedRoute = []; // porción RESTANTE (la no recorrida)
  List<LatLng> _fullPlannedRoute =
      []; // ruta completa original (para recálculo)
  String? _plannedDestinationName;
  bool _routeLoading = false;
  bool _isRerouting = false; // recalculando ruta actualmente
  static const _kOffRouteMeters = 50.0; // desvío máximo tolerado (m)
  static const _kDirectionsApiKey = 'AIzaSyDiMK4kwhaIkuMxAcioRonPzaozDRJtO20';

  List<TrackPoint> get points => _points;
  List<RideTrackEntity> get history => _history;
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  LatLng? get livePosition => _livePosition;
  List<LatLng> get plannedRoute => _plannedRoute;
  String? get plannedDestinationName => _plannedDestinationName;
  bool get routeLoading => _routeLoading;
  bool get isRerouting => _isRerouting;
  double get totalKm => _totalKm;
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;
  int get durationSec => _durationSec;
  int get calories => (_totalKm * 30).toInt();

  /// Verdadero solo cuando la velocidad GPS indica movimiento en bicicleta (≥ 3 km/h).
  bool get isMoving => _currentSpeed >= 3.0;

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

  // ─── POSICIÓN EN VIVO (avant tracking) ────────────────────
  /// Pide permiso GPS y empieza a escuchar la posición en tiempo real.
  Future<void> initLivePosition() async {
    if (_livePosSub != null) return; // ya iniciado
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever)
        return;

      // Posición inicial rápida
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _livePosition = LatLng(pos.latitude, pos.longitude);
      notifyListeners();

      // Stream continuo para actualizar en tiempo real
      _livePosSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((p) {
            _livePosition = LatLng(p.latitude, p.longitude);
            notifyListeners();
          });
    } catch (e) {
      debugPrint('initLivePosition error: $e');
    }
  }

  void _stopLivePositionStream() {
    _livePosSub?.cancel();
    _livePosSub = null;
  }

  // ─── RUTA PLANEADA ────────────────────────────────────────
  void setPlannedRoute(List<LatLng> points, String destinationName) {
    _plannedRoute = List.from(points);
    _fullPlannedRoute = List.from(
      points,
    ); // guarda la ruta completa para recálculo
    _plannedDestinationName = destinationName;
    notifyListeners();
  }

  void setRouteLoading(bool v) {
    _routeLoading = v;
    notifyListeners();
  }

  void clearPlannedRoute() {
    _plannedRoute = [];
    _fullPlannedRoute = [];
    _plannedDestinationName = null;
    _isRerouting = false;
    notifyListeners();
  }

  // ─── NAVEGACIÓN EN VIVO ───────────────────────────────────

  /// Distancia haversine en metros entre dos LatLng.
  double _distMeters(LatLng a, LatLng b) =>
      _calcDist(a.latitude, a.longitude, b.latitude, b.longitude) * 1000;

  /// Devuelve el índice del punto de la ruta más cercano a [pos].
  int _nearestRouteIndex(LatLng pos) {
    double best = double.infinity;
    int idx = 0;
    for (int i = 0; i < _plannedRoute.length; i++) {
      final d = _distMeters(pos, _plannedRoute[i]);
      if (d < best) {
        best = d;
        idx = i;
      }
    }
    return idx;
  }

  /// Llamado cada vez que llega una posición GPS durante el tracking.
  /// • Recorta la porción ya transitada de la ruta.
  /// • Si el ciclista se desvía ≥ 50 m, recalcula.
  void _updateNavigation(LatLng pos) {
    if (_plannedRoute.isEmpty || _fullPlannedRoute.isEmpty) return;

    // 1. Encontrar el punto de la ruta más cercano
    final nearIdx = _nearestRouteIndex(pos);
    final distToRoute = _distMeters(pos, _plannedRoute[nearIdx]);

    // 2. Consumir la ruta: eliminar todos los puntos ya superados
    if (nearIdx > 0) {
      _plannedRoute = _plannedRoute.sublist(nearIdx);
      notifyListeners();
    }

    // 3. Detectar desvío y recalcular
    if (distToRoute > _kOffRouteMeters && !_isRerouting) {
      _rerouteFrom(pos);
    }
  }

  /// Recalcula la ruta desde la posición actual hasta el destino original.
  Future<void> _rerouteFrom(LatLng origin) async {
    if (_fullPlannedRoute.isEmpty || _isRerouting) return;
    _isRerouting = true;
    notifyListeners();

    final destination = _fullPlannedRoute.last;
    debugPrint('🔄 Recalculando ruta desde $origin hasta $destination');

    try {
      final points = await _fetchRoute(origin, destination);
      if (points != null && points.isNotEmpty) {
        _plannedRoute = points;
        _fullPlannedRoute = List.from(points);
        debugPrint('✅ Ruta recalculada con ${points.length} puntos');
      } else {
        debugPrint('⚠️ No se pudo recalcular ruta');
      }
    } catch (e) {
      debugPrint('_rerouteFrom error: $e');
    } finally {
      _isRerouting = false;
      notifyListeners();
    }
  }

  /// Llama a Google Directions y devuelve puntos detallados paso a paso.
  Future<List<LatLng>?> _fetchRoute(LatLng origin, LatLng dest) async {
    for (final mode in ['bicycling', 'driving']) {
      try {
        final url =
            'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${origin.latitude},${origin.longitude}'
            '&destination=${dest.latitude},${dest.longitude}'
            '&mode=$mode&alternatives=false&units=metric'
            '&key=$_kDirectionsApiKey';
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 12));
        if (res.statusCode != 200) continue;
        final data = jsonDecode(res.body);
        if (data['status'] != 'OK' || (data['routes'] as List).isEmpty)
          continue;
        final steps = data['routes'][0]['legs'][0]['steps'] as List;
        final points = <LatLng>[];
        for (final step in steps) {
          points.addAll(_decodePolyline(step['polyline']['points'] as String));
        }
        if (points.isNotEmpty) return points;
      } catch (_) {}
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    final list = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      list.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return list;
  }

  /// Inicia tracking. Retorna null si OK, o String con error.
  Future<String?> startTracking() async {
    // Al iniciar tracking, el live stream se torna redundante —
    // el tracking stream lo reemplazará.
    _stopLivePositionStream();

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
            // best: usa GPS + wifi + red para máxima exactitud
            accuracy: LocationAccuracy.best,
            // Solo emite si el dispositivo se movió ≥ 10 m reales
            // evita el ruido de posición estando quieto
            distanceFilter: 10,
          ),
        ).listen(
          (pos) {
            if (_isPaused) return;

            // FILTRO 1: Precisión GPS insuficiente (pérdida de señal, inicio de adquisición)
            // Si el margen de error es > 20 m, el punto no es confiable
            if (pos.accuracy > 20.0) return;

            // pos.speed viene en m/s del chipset GPS (método Doppler, muy exacto)
            final speedKmh = pos.speed * 3.6;

            final pt = TrackPoint(
              lat: pos.latitude,
              lng: pos.longitude,
              elevation: pos.altitude,
              speed: speedKmh,
              timestamp: DateTime.now(),
            );

            if (_points.isNotEmpty) {
              // FILTRO 2: Velocidad mínima para contar distancia.
              // < 3 km/h significa que el ciclista está detenido o es ruido GPS.
              // pos.speed ≈ 0 cuando el dispositivo está quieto (aunque GPS fluctúe).
              if (pos.speed >= 0.84) {
                // 0.84 m/s ≈ 3 km/h
                final last = _points.last;
                final segKm = _calcDist(last.lat, last.lng, pt.lat, pt.lng);

                // FILTRO 3: Segmento mínimo de 8 m — ignora jitter residual
                // FILTRO 4: Segmento máximo de 300 m — evita saltos por pérdida de señal
                if (segKm >= 0.008 && segKm <= 0.3) {
                  _totalKm += segKm;
                }
              }
            }

            // Mostrar 0 en pantalla cuando el ciclista está detenido
            _currentSpeed = pos.speed >= 0.5 ? speedKmh : 0.0;
            if (_currentSpeed > _maxSpeed) _maxSpeed = _currentSpeed;
            _points.add(pt);
            // Actualizar navegación: consumir ruta y detectar desvíos
            _updateNavigation(LatLng(pos.latitude, pos.longitude));
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

  Future<bool> stopAndSave(String userId, String name) async {
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
        'name': name,
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
          name: name,
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
      _totalKm = 0;
      _currentSpeed = 0;
      _maxSpeed = 0;
      _durationSec = 0;
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
    _isPaused = false;
    _posSub?.cancel();
    _posSub = null;
    _timer?.cancel();
    _timer = null;
    _points = [];
    _totalKm = 0;
    _currentSpeed = 0;
    _maxSpeed = 0;
    _durationSec = 0;
    _startTime = null;
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
            name: m['name'] ?? '',
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

  Future<void> renameRide(String trackId, String newName) async {
    try {
      await _ds.updateRideName(trackId, newName);
      final idx = _history.indexWhere((r) => r.id == trackId);
      if (idx != -1) {
        _history[idx] = _history[idx].copyWith(name: newName);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error renaming ride: $e');
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _livePosSub?.cancel();
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
