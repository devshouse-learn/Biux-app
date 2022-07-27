import 'package:biux/data/models/type_bike.dart';
import 'package:biux/data/repositories/types_bikes/types_bike_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TypesBikeFirebaseRepository extends TypesBikeRepositoryAbstract {
  static final collection = 'typesBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<List<TypeBike>> getListTypesBike() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => TypeBike.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<TypeBike>> getTypesBike(String id) async {
    try {
      final result = await firestore.collection(collection).where('id',isEqualTo: id).get();
      return result.docs
          .map(
            (e) => TypeBike.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }
}
