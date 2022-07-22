import 'package:biux/data/models/eps.dart';
import 'package:biux/data/repositories/eps/eps_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EpsFirebaseRepository extends EpsRepositoryAbstract {
  static final collection = 'eps';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<List<Eps>> getAll() async {
    try {
      final result = await _firestore.collection(collection).get();
      return result.docs
          .map(
            (doc) => Eps.fromJson(json: doc.data(), docId: doc.id),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
