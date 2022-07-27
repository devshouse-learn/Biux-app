import 'dart:io';
import 'package:biux/data/models/bike.dart';

abstract class BikeRepositoryAbstract {
  Future<Bike> getBikeRoad(int id);
  Future getBike();
  Future uploadBike(
    String id,
    File photoBikeComplete,
    File photoInvoice,
    File photoFrontal,
    File photoGroupBike,
    File photoSerial,
    File photoOwnershipCard,
  );
  Future createDatesBike(Bike bike);
  Future<Bike> updateDatesBike(Bike bike);
}
