import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/cities/domain/repositories/cities_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

class CitiesFirebaseRepository extends CitiesRepositoryAbstract {
  static final collectionCities = 'cities';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ALTO: Agregar logging
  @override
  Future<List<City>> getCities() async {
    try {
      final result = await firestore
          .collection(collectionCities)
          .orderBy("name", descending: false)
          .get();

      AppLogger.debug('Ciudades encontradas: ${result.docs.length}',
          tag: 'CitiesRepository');

      return result.docs.map((e) => City.fromJson(json: e.data())).toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo ciudades: $e',
          tag: 'CitiesRepository', error: e);
      return List.empty();
    } catch (e) {
      AppLogger.error('Error inesperado: $e',
          tag: 'CitiesRepository', error: e);
      return List.empty();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<City> getCityId(String cityId) async {
    try {
      if (cityId.isEmpty) {
        throw ValidationException('cityId', 'City ID no puede estar vacío');
      }

      final response = await firestore
          .collection(collectionCities)
          .where('id', isEqualTo: cityId)
          .get();

      if (response.docs.isEmpty) {
        AppLogger.warning('Ciudad no encontrada: $cityId',
            tag: 'CitiesRepository');
        return City();
      }

      return City.fromJson(json: response.docs.first.data());
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'CitiesRepository');
      return City();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo ciudad: $e',
          tag: 'CitiesRepository', error: e);
      return City();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<City> getSpecifiCities(int id) async {
    try {
      if (id <= 0) {
        throw ValidationException('id', 'ID debe ser mayor a 0');
      }

      final result = await firestore
          .collection(collectionCities)
          .where('id', isEqualTo: id)
          .get();

      if (result.docs.isEmpty) {
        AppLogger.warning('Ciudad no encontrada: $id',
            tag: 'CitiesRepository');
        return City();
      }

      return City.fromJson(json: result.docs.first.data());
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'CitiesRepository');
      return City();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo ciudad específica: $e',
          tag: 'CitiesRepository', error: e);
      return City();
    }
  }
}

