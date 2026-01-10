import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/features/roads/data/models/road.dart';
import 'package:biux/features/roads/data/repositories/roads_firebase_repository.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';
import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoadsListScreenBloc extends ChangeNotifier {
  final searchCityController = TextEditingController();
  final FocusNode focusNodeCity = FocusNode();
  List<City> listCities = [];
  List<Member> member = [];
  List<Road> listRoads = [];
  List<Group> listGroup = [];
  BiuxUser user = BiuxUser();

  RoadsListScreenBloc() {
    loadData();
  }

  Future<void> loadData() async {
    getRoads();
    getGroup();
    getUser();
    getCities();
    await getMember();
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<bool> setState() async {
    notifyListeners();
    return Future.value(false);
  }

  Future<List<Road>> getRoads() async {
    listRoads = await RoadsFirebaseRepository().getRoadsByCity(cityId: '1');
    notifyListeners();
    return listRoads;
  }

  Future<void> filterCities() async {
    final dataFilterCities = await CitiesFirebaseRepository().getCities();
    listCities = dataFilterCities
        .where(
          (cities) => cities.name.toLowerCase().contains(
            searchCityController.text.toLowerCase(),
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> getCities() async {
    final dataCities = await CitiesFirebaseRepository().getCities();
    listCities = dataCities;
    notifyListeners();
  }

  Future<void> onTapCities(String cityId, String nameCity) async {
    listRoads = await RoadsFirebaseRepository().getRoadsByCity(cityId: cityId);
    searchCityController.text = nameCity;
    focusNodeCity.unfocus();
    notifyListeners();
  }

  Future<bool> willPopScope() async {
    if (focusNodeCity.hasFocus) {
      focusNodeCity.unfocus();
      notifyListeners();
    } else
      SystemNavigator.pop();

    notifyListeners();
    return Future.value(false);
  }

  Future<void> getGroup() async {
    listRoads.map((e) async {
      final dataGroup = await GroupsFirebaseRepository().getSpecificGroup(
        e.group.id,
      );
      listGroup.add(dataGroup);
    }).toList();
    notifyListeners();
  }

  Future<void> getMember() async {
    member = await GroupsFirebaseRepository().getListMemberGroup();
    notifyListeners();
  }

  Future<void> onTapOutRoads(Road road) async {
    road.numberParticipants = road.numberParticipants - 1;
    road.competitorRoad = road.competitorRoad
        .where((competitor) => competitor.id != user.id)
        .toList();
    await RoadsFirebaseRepository().onTapRoad(road);
    notifyListeners();
  }

  Future<void> onTapJoinRoads(Road road) async {
    road.numberParticipants = road.numberParticipants + 1;
    road.competitorRoad.add(BiuxUser(id: user.id, fullName: user.fullName));
    await RoadsFirebaseRepository().onTapRoad(road);
    notifyListeners();
  }
}
