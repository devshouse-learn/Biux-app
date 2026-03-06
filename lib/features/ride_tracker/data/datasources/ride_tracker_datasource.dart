import "package:cloud_firestore/cloud_firestore.dart";

class RideTrackerDatasource {
  final _fs = FirebaseFirestore.instance;

  Future<String> saveTrackFast(String userId, Map<String, dynamic> summary) async {
    final doc = await _fs.collection("ride_tracks").add({
      ...summary,
      "userId": userId,
      "createdAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> saveTrackPoints(String trackId, List<Map<String, dynamic>> points) async {
    const chunkSize = 200;
    for (int i = 0; i < points.length; i += chunkSize) {
      final end = (i + chunkSize < points.length) ? i + chunkSize : points.length;
      final chunk = points.sublist(i, end);
      await _fs.collection("ride_tracks").doc(trackId).collection("points").add({
        "data": chunk,
        "chunkIndex": i ~/ chunkSize,
      });
    }
  }

  /// Query con orderBy (requiere índice compuesto en Firestore)
  Future<List<Map<String, dynamic>>> getUserTracks(String userId) async {
    final s = await _fs
        .collection("ride_tracks")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .limit(50)
        .get();
    return s.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  /// Fallback sin orderBy (no requiere índice compuesto)
  Future<List<Map<String, dynamic>>> getUserTracksSimple(String userId) async {
    final s = await _fs
        .collection("ride_tracks")
        .where("userId", isEqualTo: userId)
        .limit(50)
        .get();
    return s.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  Future<void> deleteTrack(String trackId) async {
    try {
      final pointsDocs = await _fs
          .collection("ride_tracks")
          .doc(trackId)
          .collection("points")
          .get();
      for (final doc in pointsDocs.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}
    await _fs.collection("ride_tracks").doc(trackId).delete();
  }
}
