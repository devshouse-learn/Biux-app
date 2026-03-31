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
}
