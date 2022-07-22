import 'package:biux/data/models/type_bike.dart';

abstract class TypesBikeRepositoryAbstract {
  Future<List<TypeBike>> getListTradeMarks();
  Future<List<TypeBike>> getTypesBike();
  Future sendDatesTypesBike(TypeBike typeBike);
}
