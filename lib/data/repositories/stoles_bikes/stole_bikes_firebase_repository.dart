import 'package:biux/data/models/stole_bikes.dart';
import 'package:biux/data/repositories/stoles_bikes/stole_bikes_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoleBikesFirebaseRepository extends StoleBikesRepositoryAbstract {
  static final collection = 'stoleBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future getBike() {
    // TODO: implement getBike
    throw UnimplementedError();
  }

  @override
  Future<StoleBikes> getStoleBikes(int id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: id.toString())
          .get();
      return StoleBikes.fromjson(
        response.docs.first.data(),
      );
    } catch (e) {
      return StoleBikes();
    }
  }

  @override
  Future sendDatesStoleBikes(StoleBikes stoleBikes) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(stoleBikes.id.toString())
          .set(stoleBikes.toJson());
    } catch (e) {}
  }

  @override
  Future updateDatesStoleBikes(StoleBikes stoleBikes) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(stoleBikes.id.toString())
          .update(stoleBikes.toJson());
    } catch (e) {}
  }
}
