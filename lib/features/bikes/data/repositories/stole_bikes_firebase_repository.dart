import 'package:biux/features/bikes/data/models/stole_bikes.dart';
import 'package:biux/features/bikes/domain/repositories/stole_bikes_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:biux/core/config/strings.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

class StoleBikesFirebaseRepository extends StoleBikesRepositoryAbstract {
  static final collection = 'stoleBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  /// ALTO: Agregar logging de errores
  @override
  Future<List<StoleBikes>> getBike() async {
    try {
      final response = await firestore.collection(collection).get();
      AppLogger.debug('Bicicletas robadas encontradas: ${response.docs.length}',
          tag: 'StoleBikesRepository');
      return response.docs
          .map((doc) => StoleBikes.fromjson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo bicicletas robadas: $e',
          tag: 'StoleBikesRepository', error: e);
      return [];
    } catch (e) {
      AppLogger.error('Error inesperado obteniendo bicicletas: $e',
          tag: 'StoleBikesRepository', error: e);
      return [];
    }
  }

  /// ALTO: Validar entrada y mejor error handling
  @override
  Future<StoleBikes> getStoleBikes(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('id', 'ID no puede estar vacío');
      }

      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();

      if (response.docs.isEmpty) {
        AppLogger.warning('Bicicleta robada no encontrada: $id',
            tag: 'StoleBikesRepository');
        return StoleBikes();
      }

      return StoleBikes.fromjson(response.docs.first.data());
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'StoleBikesRepository');
      return StoleBikes();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo bicicleta robada: $e',
          tag: 'StoleBikesRepository', error: e);
      return StoleBikes();
    } catch (e) {
      AppLogger.error('Error inesperado: $e',
          tag: 'StoleBikesRepository', error: e);
      return StoleBikes();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future createDatesStoleBikes(StoleBikes stoleBikes) async {
    try {
      if (stoleBikes.id == null || stoleBikes.id!.isEmpty) {
        AppLogger.warning('ID vacío en bicicleta robada', tag: 'StoleBikesRepository');
        throw ValidationException('id', 'ID es requerido');
      }

      final docRef = await firestore.collection(collection).add(stoleBikes.toJson());
      await firestore.collection(collection).doc(docRef.id).update({
        AppStrings.idText: docRef.id,
      });

      AppLogger.info('Bicicleta robada creada: ${docRef.id}',
          tag: 'StoleBikesRepository');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'StoleBikesRepository');
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Error creando bicicleta robada: $e',
          tag: 'StoleBikesRepository', error: e);
      rethrow;
    } catch (e) {
      AppLogger.error('Error inesperado: $e',
          tag: 'StoleBikesRepository', error: e);
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future updateDatesStoleBikes(StoleBikes stoleBikes) async {
    try {
      if (stoleBikes.id == null || stoleBikes.id!.isEmpty) {
        throw ValidationException('id', 'ID es requerido para actualizar');
      }

      await firestore
          .collection(collection)
          .doc(stoleBikes.id)
          .update(stoleBikes.toJson());

      AppLogger.info('Bicicleta robada actualizada: ${stoleBikes.id}',
          tag: 'StoleBikesRepository');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'StoleBikesRepository');
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Error actualizando bicicleta robada: $e',
          tag: 'StoleBikesRepository', error: e);
      rethrow;
    } catch (e) {
      AppLogger.error('Error inesperado: $e',
          tag: 'StoleBikesRepository', error: e);
      rethrow;
    }
  }
}

