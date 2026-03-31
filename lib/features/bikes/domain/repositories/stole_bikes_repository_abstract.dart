import 'package:biux/features/bikes/data/models/stole_bikes.dart';

abstract class StoleBikesRepositoryAbstract {
  Future<StoleBikes> getStoleBikes(String id);
  Future getBike();
  Future createDatesStoleBikes(StoleBikes stoleBikes);
  Future updateDatesStoleBikes(StoleBikes stoleBikes);
}
