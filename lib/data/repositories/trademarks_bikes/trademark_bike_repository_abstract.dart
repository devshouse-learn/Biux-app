import 'package:biux/data/models/trademark_bike.dart';

abstract class TrademarkBikeRepositoryAbstract {
  Future<List<TrademarkBike>> getListTrademarks();
  Future<List<TrademarkBike>> getTrademarksBike(String trademark);
  Future sendDatesTrademarkBike(TrademarkBike trademarkBike);
}
