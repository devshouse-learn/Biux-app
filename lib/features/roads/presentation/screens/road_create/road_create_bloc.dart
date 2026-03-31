import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/roads/data/models/road.dart';
import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';
import 'package:biux/features/roads/data/repositories/roads_firebase_repository.dart';
import 'package:flutter/material.dart';

class RoadCreateBloc extends ChangeNotifier {
  double rating = 1.0;
  final Group group;
  List<City> listCities = [];
  City dropdownValueCity = City();
  final RoadsFirebaseRepository roadsFirebaseRepository =
      RoadsFirebaseRepository();
  final CitiesFirebaseRepository citiesFirebaseRepository =
      CitiesFirebaseRepository();

  RoadCreateBloc({required this.group}) {
    getCities();
  }

  void changeRating(double rating) {
    this.rating = rating;
    notifyListeners();
  }

  Future<bool> createRoad(Road road) async {
    final result = await roadsFirebaseRepository.createRoad(road);
    notifyListeners();
    return result;
  }

  void getCities() async {
    listCities = await citiesFirebaseRepository.getCities();
    final city = listCities
        .where((element) => element.id == group.cityId)
        .toList();
    dropdownValueCity = city.first;
    notifyListeners();
  }

  void replaceDropdownValueCity(String newValue) {
    final city = listCities
        .where((element) => element.name == newValue)
        .toList();
    this.dropdownValueCity = city.first;
    notifyListeners();
  }
}
