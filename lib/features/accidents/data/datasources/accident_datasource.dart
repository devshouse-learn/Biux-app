import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/accidents/domain/entities/accident_entity.dart';

class AccidentDatasource {
  final _fs = FirebaseFirestore.instance;
  final _col = 'accidents';

  Future<void> reportAccident(AccidentEntity accident) async {
    final map = accident.toMap();
    // Usar serverTimestamp para que Firestore pueda ordenar correctamente
    map['createdAt'] = FieldValue.serverTimestamp();
    await _fs.collection(_col).add(map);
  }

  Stream<List<AccidentEntity>> getRecentAccidents() {
    return _fs
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AccidentEntity.fromMap(d.id, d.data()))
              .where((a) => !a.resolved)
              .toList(),
        );
  }

  Future<void> resolveAccident(String id) async {
    await _fs.collection(_col).doc(id).update({'resolved': true});
  }

  /// RENDIMIENTO: Chunk batch operations (max 500 per batch)
  Future<void> deleteAllAccidents() async {
    final snapshot = await _fs.collection(_col).get();
    const int batchSize = 500;

    for (int i = 0; i < snapshot.docs.length; i += batchSize) {
      final batch = _fs.batch();
      final chunk = snapshot.docs.sublist(
        i,
        (i + batchSize).clamp(0, snapshot.docs.length),
      );

      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// RENDIMIENTO: Chunk batch operations (max 500 per batch)
  Future<void> deleteResolvedAccidents() async {
    final snapshot = await _fs
        .collection(_col)
        .where('resolved', isEqualTo: true)
        .get();
    const int batchSize = 500;

    for (int i = 0; i < snapshot.docs.length; i += batchSize) {
      final batch = _fs.batch();
      final chunk = snapshot.docs.sublist(
        i,
        (i + batchSize).clamp(0, snapshot.docs.length),
      );

      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
