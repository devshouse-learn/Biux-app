import 'package:biux/features/bikes/data/models/stole_bikes.dart';
import 'package:biux/features/bikes/domain/repositories/stole_bikes_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:biux/core/config/strings.dart';

class StoleBikesFirebaseRepository extends StoleBikesRepositoryAbstract {
  static final collection = 'stoleBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future getBike() {
    // TODO: implement getBike
    throw UnimplementedError();
  }

  @override
  Future<StoleBikes> getStoleBikes(String id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: id.toString())
          .get();
      return StoleBikes.fromjson(response.docs.first.data());
    } catch (e) {
      return StoleBikes();
    }
  }

  @override
  Future createDatesStoleBikes(StoleBikes stoleBikes) async {
    try {
      await firestore.collection(collection).add(stoleBikes.toJson()).then((
        DocumentReference doc,
      ) {
        String docId = doc.id;
        firestore.collection(collection).doc(docId).update({
          AppStrings.idText: docId,
        });
      });
    } catch (e) {}
  }

  @override
  Future updateDatesStoleBikes(StoleBikes stoleBikes) async {
    try {
      await firestore
          .collection(collection)
          .doc(stoleBikes.id)
          .update(stoleBikes.toJson());
    } catch (e) {}
  }
}
