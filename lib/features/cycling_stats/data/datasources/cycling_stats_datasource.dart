
import 'package:cloud_firestore/cloud_firestore.dart';

class CyclingStatsDatasource {
  final FirebaseFirestore _firestore;

  CyclingStatsDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getStats(String userId) async {
    final doc = await _firestore.collection('cycling_stats').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> saveStats(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('cycling_stats').doc(userId).set(data, SetOptions(merge: true));
  }

  Future<void> addRideStats(String userId, {
    required double km,
    required double avgSpeed,
    required double maxSpeed,
    required int elevation,
    required int minutes,
  }) async {
    final ref = _firestore.collection('cycling_stats').doc(userId);
    final now = DateTime.now();
    final monthKey = '\${now.year}-\${now.month.toString().padLeft(2, "0")}';

    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final data = doc.data() ?? {};

      final currentKm = (data['totalKm'] as num?)?.toDouble() ?? 0;
      final currentRides = (data['totalRides'] as num?)?.toInt() ?? 0;
      final currentAvg = (data['avgSpeed'] as num?)?.toDouble() ?? 0;
      final currentMax = (data['maxSpeed'] as num?)?.toDouble() ?? 0;
      final currentElevation = (data['totalElevation'] as num?)?.toInt() ?? 0;
      final currentCalories = (data['totalCalories'] as num?)?.toInt() ?? 0;
      final currentMinutes = (data['totalMinutes'] as num?)?.toInt() ?? 0;
      final monthlyKm = Map<String, dynamic>.from(data['monthlyKm'] ?? {});

      final newTotalKm = currentKm + km;
      final newTotalRides = currentRides + 1;
      final newAvg = ((currentAvg * currentRides) + avgSpeed) / newTotalRides;
      final newMax = maxSpeed > currentMax ? maxSpeed : currentMax;
      final calories = (km * 30).toInt(); // ~30 cal/km estimado

      monthlyKm[monthKey] = ((monthlyKm[monthKey] as num?)?.toDouble() ?? 0) + km;

      // Calcular racha
      final lastRide = data['lastRideDate'] != null
          ? (data['lastRideDate'] as Timestamp).toDate()
          : null;
      int streak = (data['streak'] as num?)?.toInt() ?? 0;
      if (lastRide != null) {
        final diff = now.difference(lastRide).inDays;
        if (diff <= 1) {
          streak++;
        } else {
          streak = 1;
        }
      } else {
        streak = 1;
      }

      // Nivel
      String level = 'novato';
      if (newTotalKm >= 10000) level = 'leyenda';
      else if (newTotalKm >= 5000) level = 'experto';
      else if (newTotalKm >= 1000) level = 'avanzado';
      else if (newTotalKm >= 200) level = 'intermedio';

      tx.set(ref, {
        'userId': userId,
        'totalKm': newTotalKm,
        'totalRides': newTotalRides,
        'avgSpeed': newAvg,
        'maxSpeed': newMax,
        'totalElevation': currentElevation + elevation,
        'totalCalories': currentCalories + calories,
        'totalMinutes': currentMinutes + minutes,
        'streak': streak,
        'level': level,
        'lastRideDate': Timestamp.fromDate(now),
        'monthlyKm': monthlyKm,
      }, SetOptions(merge: true));
    });
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('cycling_stats')
        .orderBy('totalKm', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
