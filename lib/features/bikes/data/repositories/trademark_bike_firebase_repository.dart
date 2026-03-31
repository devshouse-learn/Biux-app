import 'package:biux/features/bikes/data/models/trademark_bike.dart';
import 'package:biux/features/bikes/domain/repositories/trademark_bike_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrademarkBikeFirebaseRepository extends TrademarkBikeRepositoryAbstract {
  static final collection = 'trademarksBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<List<TrademarkBike>> getListTrademarks() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map((e) => TrademarkBike.fromJsonMap(e.data()))
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<TrademarkBike>> getTrademarksBike(String trademark) async {
    try {
      final result = await firestore
          .collection(collection)
          .where('trademark', isEqualTo: trademark)
          .get();
      return result.docs
          .map((e) => TrademarkBike.fromJsonMap(e.data()))
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future createTrademarkBike(TrademarkBike trademarkBike) async {
    try {
      await firestore
          .collection(collection)
          .doc(trademarkBike.id.toString())
          .set(trademarkBike.toJson());
    } catch (e) {}
  }
}
