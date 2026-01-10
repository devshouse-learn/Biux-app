import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingPointRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'meeting_points';

  MeetingPointRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<MeetingPoint>> getMeetingPoints() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MeetingPoint.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  Future<MeetingPoint?> getMeetingPoint(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return MeetingPoint.fromJson({'id': doc.id, ...doc.data()!});
    }
    return null;
  }
}
