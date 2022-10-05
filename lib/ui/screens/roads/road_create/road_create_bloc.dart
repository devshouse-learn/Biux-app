import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/repositories/roads/roads_firebase_repository.dart';
import 'package:flutter/material.dart';

class RoadCreateBloc extends ChangeNotifier {
  double rating = 1.0;
  final Group group;
  final RoadsFirebaseRepository roadsFirebaseRepository =
      RoadsFirebaseRepository();

  RoadCreateBloc({
    required this.group,
  });

  void changeRating(double rating) {
    this.rating = rating;
    notifyListeners();
  }

  Future<bool> createRoad(Road road) async {
    final result = await roadsFirebaseRepository.createRoad(road);
    notifyListeners();
    return result;
  }
}
