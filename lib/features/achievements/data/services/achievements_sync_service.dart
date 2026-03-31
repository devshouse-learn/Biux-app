import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que sincroniza logros automaticamente cada semana
/// o cuando el usuario abre la pantalla de logros
class AchievementsSyncService {
  static const _lastSyncKey = 'achievements_last_sync';
  static const _syncIntervalDays = 7;

  /// Verifica si necesita sincronizar y lo hace si es necesario
  static Future<void> syncIfNeeded(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final daysSinceSync = (now - lastSync) / (1000 * 60 * 60 * 24);

      if (daysSinceSync >= _syncIntervalDays) {
        debugPrint(
          '🔄 Logros: Sincronizando (ultima vez hace \${daysSinceSync.toInt()} dias)',
        );
        await fullSync(userId);
        await prefs.setInt(_lastSyncKey, now);
        debugPrint('✅ Logros: Sincronizacion semanal completada');
      } else {
        debugPrint(
          '⏭️ Logros: No necesita sincronizar (faltan \${(_syncIntervalDays - daysSinceSync).toInt()} dias)',
        );
      }
    } catch (e) {
      debugPrint('❌ Error en sincronizacion semanal de logros: \$e');
    }
  }

  /// Fuerza una sincronizacion completa de logros
  static Future<void> fullSync(String userId) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Obtener historial completo de rodadas
    double accumKm = 0;
    double bestMaxSpeed = 0;
    double maxSingleKm = 0;
    int totalRides = 0;
    final List<DateTime> rideDates = [];

    try {
      final tracksSnap = await firestore
          .collection('ride_tracks')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      totalRides = tracksSnap.docs.length;

      for (final doc in tracksSnap.docs) {
        final data = doc.data();
        final singleKm = (data['totalKm'] as num?)?.toDouble() ?? 0;
        accumKm += singleKm;
        if (singleKm > maxSingleKm) maxSingleKm = singleKm;
        final maxSpd = (data['maxSpeed'] as num?)?.toDouble() ?? 0;
        if (maxSpd > bestMaxSpeed) bestMaxSpeed = maxSpd;

        final startMs = data['startTime'] as int?;
        if (startMs != null) {
          rideDates.add(DateTime.fromMillisecondsSinceEpoch(startMs));
        }
      }
    } catch (e) {
      debugPrint('Error obteniendo historial de rodadas: \$e');
    }

    // 2. Calcular racha de dias consecutivos
    final streak = _calculateStreak(rideDates);

    // 3. Contar grupos del usuario
    int groupCount = 0;
    try {
      final groupSnap = await firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();
      groupCount = groupSnap.docs.length;
    } catch (e) {
      debugPrint('Error: ' + e.toString());
    }

    // 4. Detectar logros especiales
    bool hasNightRide = false;
    bool hasEarlyBird = false;
    bool hasWeekendWarrior = false;
    bool hasEveningRide = false;
    final Set<String> weekendKeys = {};
    for (final date in rideDates) {
      if (date.hour >= 20 || date.hour < 5) hasNightRide = true;
      if (date.hour < 6) hasEarlyBird = true;
      if (date.hour >= 18 && date.hour < 21) hasEveningRide = true;
      final weekKey = '${date.year}-W${_isoWeek(date)}';
      if (date.weekday == DateTime.saturday) weekendKeys.add('$weekKey-sat');
      if (date.weekday == DateTime.sunday) weekendKeys.add('$weekKey-sun');
    }
    for (final key in weekendKeys) {
      if (key.endsWith('-sat') &&
          weekendKeys.contains('${key.replaceAll('-sat', '')}-sun')) {
        hasWeekendWarrior = true;
        break;
      }
    }

    // 5. Guardar stats acumuladas
    await firestore.collection('user_stats').doc(userId).set({
      'totalKm': accumKm,
      'totalRides': totalRides,
      'maxSpeed': bestMaxSpeed,
      'maxSingleKm': maxSingleKm,
      'streak': streak,
      'groupCount': groupCount,
      'lastSyncAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 6. Obtener logros actuales para no sobreescribir timestamps
    final achievementsDoc = await firestore
        .collection('achievements')
        .doc(userId)
        .get();
    final currentData = achievementsDoc.data() ?? {};

    // 7. Actualizar cada logro
    final Map<String, dynamic> updates = {};

    // Escribe currentValue para un logro; isUnlocked se computa en el cliente
    void writeMetric(String id, double value, double maxTarget) {
      final wasUnlocked =
          (currentData[id] as Map<String, dynamic>?)?['unlocked'] == true;
      final nowUnlocked = value >= maxTarget;
      updates[id] = {
        'currentValue': value,
        'unlocked': nowUnlocked,
        if (nowUnlocked && !wasUnlocked)
          'unlockedAt': FieldValue.serverTimestamp(),
      };
    }

    // Distancia (accumKm)
    writeMetric('dist_explorer', accumKm, 200);
    writeMetric('dist_traveler', accumKm, 1000);
    writeMetric('dist_runner', accumKm, 5000);
    writeMetric('dist_ultra', accumKm, 20000);
    writeMetric('dist_legend', accumKm, 100000);

    // Rodadas (totalRides)
    writeMetric('rides_starter', totalRides.toDouble(), 12);
    writeMetric('rides_regular', totalRides.toDouble(), 58);
    writeMetric('rides_veteran', totalRides.toDouble(), 150);
    writeMetric('rides_master', totalRides.toDouble(), 400);
    writeMetric('rides_legend', totalRides.toDouble(), 1000);

    // Velocidad punta (bestMaxSpeed)
    writeMetric('speed_cruiser', bestMaxSpeed, 30);
    writeMetric('speed_sprinter', bestMaxSpeed, 40);
    writeMetric('speed_racer', bestMaxSpeed, 50);
    writeMetric('speed_rocket', bestMaxSpeed, 65);
    writeMetric('speed_sonic', bestMaxSpeed, 90);

    // Racha (streak dias consecutivos)
    writeMetric('streak_init', streak.toDouble(), 14);
    writeMetric('streak_habit', streak.toDouble(), 35);
    writeMetric('streak_machine', streak.toDouble(), 75);
    writeMetric('streak_iron', streak.toDouble(), 150);
    writeMetric('streak_legend', streak.toDouble(), 365);

    // Social (groupCount)
    writeMetric('social_member', groupCount.toDouble(), 10);
    writeMetric('social_popular', groupCount.toDouble(), 40);
    writeMetric('social_connector', groupCount.toDouble(), 120);
    writeMetric('social_networker', groupCount.toDouble(), 320);
    writeMetric('social_ambassador', groupCount.toDouble(), 750);

    // Aventura (maxSingleKm - mejor rodada unica)
    writeMetric('aventura_start', maxSingleKm, 60);
    writeMetric('aventura_explorer', maxSingleKm, 180);
    writeMetric('aventura_fondo', maxSingleKm, 450);
    writeMetric('aventura_ultra', maxSingleKm, 870);
    writeMetric('aventura_expedition', maxSingleKm, 1440);

    // Especiales
    _specialCheck(updates, currentData, 'night_ride', hasNightRide);
    _specialCheck(updates, currentData, 'early_bird', hasEarlyBird);
    _specialCheck(updates, currentData, 'weekend_warrior', hasWeekendWarrior);
    _specialCheck(updates, currentData, 'evening_ride', hasEveningRide);
    _specialCheck(updates, currentData, 'long_single', maxSingleKm >= 80);

    await firestore
        .collection('achievements')
        .doc(userId)
        .set(updates, SetOptions(merge: true));

    debugPrint(
      '📊 Sync completo: \${accumKm.toStringAsFixed(1)} km, \$totalRides rodadas, max \${bestMaxSpeed.toStringAsFixed(1)} km/h, racha \$streak dias, \$groupCount grupos',
    );
  }

  static void _specialCheck(
    Map<String, dynamic> updates,
    Map<String, dynamic> currentData,
    String id,
    bool condition,
  ) {
    if (condition) {
      final wasUnlocked =
          (currentData[id] as Map<String, dynamic>?)?['unlocked'] == true;
      updates[id] = {
        'currentValue': 1.0,
        'unlocked': true,
        if (!wasUnlocked) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    } else {
      updates[id] = {'currentValue': 0.0, 'unlocked': false};
    }
  }

  static int _isoWeek(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final yearStart = DateTime(thursday.year, 1, 1);
    return ((thursday.difference(yearStart).inDays) / 7).ceil();
  }

  static int _calculateStreak(List<DateTime> rideDates) {
    if (rideDates.isEmpty) return 0;
    final dates =
        rideDates.map((r) => DateTime(r.year, r.month, r.day)).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // Si no pedaleo hoy ni ayer, racha es 0
    if (dates.isEmpty) return 0;
    final diff = today.difference(dates.first).inDays;
    if (diff > 1) return 0;

    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final d = dates[i].difference(dates[i + 1]).inDays;
      if (d == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
