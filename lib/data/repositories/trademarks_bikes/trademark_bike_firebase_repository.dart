import 'package:biux/data/models/trademark_bike.dart';
import 'package:biux/data/repositories/trademarks_bikes/trademark_bike_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrademarkBikeFirebaseRepository extends TrademarkBikeRepositoryAbstract {
  static final collection = 'trademarksBikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<List<TrademarkBike>> getListTrademarks() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => TrademarkBike.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<TrademarkBike>> getTrademarksBike() async {
    try {
      final result = await firestore.collection(collection).get();
      return result.docs
          .map(
            (e) => TrademarkBike.fromJsonMap(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future sendDatesTrademarkBike(TrademarkBike trademarkBike) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(trademarkBike.id.toString())
          .set(trademarkBike.toJson());
    } catch (e) {}
  }
}
