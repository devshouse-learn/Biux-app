import 'package:biux/data/models/type_bike.dart';

abstract class TypesBikeRepositoryAbstract {
  Future<List<TypeBike>> getListTypesBike();
  Future<List<TypeBike>> getTypesBike(String id);
}
