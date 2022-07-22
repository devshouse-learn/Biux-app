import 'package:biux/data/models/advertising.dart';
import 'package:biux/data/repositories/advertisements/advertising_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvertisingFirebaseRepository extends AdvertisingRepositoryAbstract {
  static const collection = 'advertising';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<Advertising> getAdvertising() async {
    try {
      final result = await _firestore.collection(collection).get();
      return (result.docs
          .map(
            (doc) {
              print(doc.data());
              return Advertising.fromJsonMap(
              json: doc.data(),
              docId: doc.id
            );
            },
          )
          .toList()
          ..shuffle())
          .first;
    } catch (e) {
      print(e);
      throw Exception();
    }
  }

}
