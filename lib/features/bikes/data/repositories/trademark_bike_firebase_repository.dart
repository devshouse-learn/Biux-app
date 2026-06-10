import 'package:biux/features/bikes/data/models/trademark_bike.dart';
import 'package:biux/features/bikes/domain/repositories/trademark_bike_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

class TrademarkBikeFirebaseRepository extends TrademarkBikeRepositoryAbstract {
  static final collection = 'trademarksBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  /// ALTO: Agregar logging de errores
  @override
  Future<List<TrademarkBike>> getListTrademarks() async {
    try {
      final result = await firestore.collection(collection).get();
      AppLogger.debug('Marcas encontradas: ${result.docs.length}',
          tag: 'TrademarkBikeRepository');
      return result.docs
          .map((e) => TrademarkBike.fromJsonMap(e.data()))
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo marcas: $e',
          tag: 'TrademarkBikeRepository', error: e);
      return List.empty();
    }
  }

  /// ALTO: Validar entrada y agregar logging
  @override
  Future<List<TrademarkBike>> getTrademarksBike(String trademark) async {
    try {
      if (trademark.isEmpty) {
        throw ValidationException('trademark', 'Marca no puede estar vacía');
      }

      final result = await firestore
          .collection(collection)
          .where('trademark', isEqualTo: trademark)
          .get();

      AppLogger.debug('Bicicletas de marca encontradas: ${result.docs.length}',
          tag: 'TrademarkBikeRepository');

      return result.docs
          .map((e) => TrademarkBike.fromJsonMap(e.data()))
          .toList();
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'TrademarkBikeRepository');
      return List.empty();
    } on FirebaseException catch (e) {
      AppLogger.error('Error obteniendo bicicletas por marca: $e',
          tag: 'TrademarkBikeRepository', error: e);
      return List.empty();
    }
  }

  /// ALTO: Agregar logging
  @override
  Future createTrademarkBike(TrademarkBike trademarkBike) async {
    try {
      if (trademarkBike.id == null || trademarkBike.id.toString().isEmpty) {
        throw ValidationException('id', 'ID de marca es requerido');
      }

      await firestore
          .collection(collection)
          .doc(trademarkBike.id.toString())
          .set(trademarkBike.toJson());

      AppLogger.info('Marca de bicicleta creada: ${trademarkBike.id}',
          tag: 'TrademarkBikeRepository');
    } on ValidationException catch (e) {
      AppLogger.warning('Validación fallida: ${e.message}',
          tag: 'TrademarkBikeRepository');
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Error creando marca de bicicleta: $e',
          tag: 'TrademarkBikeRepository', error: e);
      rethrow;
    }
  }
}

