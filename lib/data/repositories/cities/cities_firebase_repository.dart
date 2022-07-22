import 'package:biux/data/models/city.dart';
import 'package:biux/data/repositories/cities/cities_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitiesFirebaseRepository extends CitiesRepositoryAbstract {
  static final collectionCities = 'cities';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<List<City>> getCities() async {
    try {
      final result = await firestore.collection(collectionCities).get();
      return result.docs
          .map(
            (e) => City.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<City> getCityId(String cityName) async {
    try {
      final response = await firestore
          .collection(collectionCities)
          .where('name', isEqualTo: cityName)
          .get();
      return City.fromJsonMap(
        response.docs.first.data(),
      );
    } catch (e) {
      return City();
    }
  }

  @override
  Future<City> getSpecifiCities(int id) async {
    try {
      final result = await firestore
          .collection(collectionCities)
          .where('id', isEqualTo: id)
          .get();
      return City.fromJsonMap(
        result.docs.first.data(),
      );
    } catch (e) {
      return City();
    }
  }
}
