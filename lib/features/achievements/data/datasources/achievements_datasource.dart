import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsDatasource {
  final FirebaseFirestore _firestore;

  AchievementsDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    final doc = await _firestore.collection('achievements').doc(userId).get();
    return doc.exists ? doc.data()! : {};
  }

  Future<void> saveAchievements(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('achievements')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    await _firestore.collection('achievements').doc(userId).set({
      achievementId: {
        'unlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> updateProgress(
    String userId,
    String achievementId,
    double value,
  ) async {
    await _firestore.collection('achievements').doc(userId).set({
      achievementId: {'currentValue': value},
    }, SetOptions(merge: true));
  }
}
