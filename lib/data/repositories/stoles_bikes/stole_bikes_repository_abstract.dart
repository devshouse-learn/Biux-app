import 'package:biux/data/models/stole_bikes.dart';

abstract class StoleBikesRepositoryAbstract {
  Future<StoleBikes> getStoleBikes(int id);
  Future getBike();
  Future sendDatesStoleBikes(StoleBikes stoleBikes);
  Future updateDatesStoleBikes(StoleBikes stoleBikes);
}
