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
        debugPrint('🔄 Logros: Sincronizando (ultima vez hace \${daysSinceSync.toInt()} dias)');
        await fullSync(userId);
        await prefs.setInt(_lastSyncKey, now);
        debugPrint('✅ Logros: Sincronizacion semanal completada');
      } else {
        debugPrint('⏭️ Logros: No necesita sincronizar (faltan \${(_syncIntervalDays - daysSinceSync).toInt()} dias)');
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
        accumKm += (data['totalKm'] as num?)?.toDouble() ?? 0;
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
    } catch (_) {}

    // 4. Detectar logros especiales (rodada nocturna/madrugadora)
    bool hasNightRide = false;
    bool hasEarlyBird = false;
    for (final date in rideDates) {
      if (date.hour >= 20 || date.hour < 5) hasNightRide = true;
      if (date.hour < 6) hasEarlyBird = true;
    }

    // 5. Guardar stats acumuladas
    await firestore.collection('user_stats').doc(userId).set({
      'totalKm': accumKm,
      'totalRides': totalRides,
      'maxSpeed': bestMaxSpeed,
      'streak': streak,
      'groupCount': groupCount,
      'lastSyncAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 6. Obtener logros actuales para no sobreescribir timestamps
    final achievementsDoc = await firestore
        .collection('achievements').doc(userId).get();
    final currentData = achievementsDoc.data() ?? {};

    // 7. Actualizar cada logro
    final Map<String, dynamic> updates = {};

    void check(String id, double current, double target) {
      final wasUnlocked = (currentData[id] as Map<String, dynamic>?)?['unlocked'] == true;
      updates[id] = {
        'currentValue': current,
        if (current >= target) 'unlocked': true,
        if (current >= target && !wasUnlocked) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }

    // Distancia
    check('km_10', accumKm, 10);
    check('km_50', accumKm, 50);
    check('km_100', accumKm, 100);
    check('km_500', accumKm, 500);
    check('km_1000', accumKm, 1000);
    check('km_5000', accumKm, 5000);

    // Rodadas
    check('rides_1', totalRides.toDouble(), 1);
    check('rides_10', totalRides.toDouble(), 10);
    check('rides_50', totalRides.toDouble(), 50);
    check('rides_100', totalRides.toDouble(), 100);

    // Velocidad
    check('speed_30', bestMaxSpeed, 30);
    check('speed_40', bestMaxSpeed, 40);
    check('speed_50', bestMaxSpeed, 50);

    // Racha
    check('streak_3', streak.toDouble(), 3);
    check('streak_7', streak.toDouble(), 7);
    check('streak_30', streak.toDouble(), 30);

    // Social
    check('group_1', groupCount.toDouble(), 1);
    check('group_5', groupCount.toDouble(), 5);

    // Especiales
    if (hasNightRide) {
      final wasUnlocked = (currentData['night_ride'] as Map<String, dynamic>?)?['unlocked'] == true;
      updates['night_ride'] = {
        'currentValue': 1.0,
        'unlocked': true,
        if (!wasUnlocked) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }
    if (hasEarlyBird) {
      final wasUnlocked = (currentData['early_bird'] as Map<String, dynamic>?)?['unlocked'] == true;
      updates['early_bird'] = {
        'currentValue': 1.0,
        'unlocked': true,
        if (!wasUnlocked) 'unlockedAt': FieldValue.serverTimestamp(),
      };
    }

    await firestore.collection('achievements').doc(userId).set(
      updates, SetOptions(merge: true),
    );

    debugPrint('📊 Sync completo: \${accumKm.toStringAsFixed(1)} km, \$totalRides rodadas, max \${bestMaxSpeed.toStringAsFixed(1)} km/h, racha \$streak dias, \$groupCount grupos');
  }

  static int _calculateStreak(List<DateTime> rideDates) {
    if (rideDates.isEmpty) return 0;
    final dates = rideDates
        .map((r) => DateTime(r.year, r.month, r.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
