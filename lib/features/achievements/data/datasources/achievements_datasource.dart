import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsDatasource {
  final FirebaseFirestore _firestore;

  AchievementsDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    final data = <String, dynamic>{};
    for (final doc in snapshot.docs) {
      data[doc.id] = doc.data();
    }
    return data;
  }

  Future<void> saveAchievements(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({
          'unlockedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> updateProgress(
    String userId,
    String achievementId,
    double value,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({
          'currentValue': value,
        }, SetOptions(merge: true));
  }
}
