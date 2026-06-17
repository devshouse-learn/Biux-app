import 'package:biux/features/bikes/data/models/type_bike.dart';
import 'package:biux/features/bikes/domain/repositories/types_bike_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

class TypesBikeFirebaseRepository extends TypesBikeRepositoryAbstract {
  static final collection = 'typesBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ALTO: Agregar logging de errores
  @override
  Future<List<TypeBike>> getListTypesBike() async {
    try {
      final result = await firestore.collection(collection).get();
      AppLogger.debug(
        'Tipos de bicicletas encontrados: ${result.docs.length}',
        tag: 'TypesBikeRepository',
      );
      return result.docs.map((e) => TypeBike.fromJsonMap(e.data())).toList();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error obteniendo tipos de bicicletas: $e',
        tag: 'TypesBikeRepository',
        error: e,
      );
      return List.empty();
    } catch (e) {
      AppLogger.error(
        'Error inesperado: $e',
        tag: 'TypesBikeRepository',
        error: e,
      );
      return List.empty();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<List<TypeBike>> getTypesBike(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('id', 'ID no puede estar vacío');
      }

      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();

      AppLogger.debug(
        'Tipos de bicicletas encontrados: ${result.docs.length}',
        tag: 'TypesBikeRepository',
      );

      return result.docs.map((e) => TypeBike.fromJsonMap(e.data())).toList();
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'TypesBikeRepository',
      );
      return List.empty();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error obteniendo tipos de bicicletas: $e',
        tag: 'TypesBikeRepository',
        error: e,
      );
      return List.empty();
    } catch (e) {
      AppLogger.error(
        'Error inesperado: $e',
        tag: 'TypesBikeRepository',
        error: e,
      );
      return List.empty();
    }
  }
}
