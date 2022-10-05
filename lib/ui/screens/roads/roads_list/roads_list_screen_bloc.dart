import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/data/repositories/roads/roads_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biux/data/local_storage/localstorage.dart';

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
    getUser();
    getRoads();
    getCities();
    getGroup();
    await getMember();
  }

  Future<void> getUser() async {
    String? userId = await LocalStorage().getUserId();
    final dataUser = await UserFirebaseRepository().getUserId(userId!);
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
        .where((cities) => cities.name
            .toLowerCase()
            .contains(searchCityController.text.toLowerCase()))
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
      final dataGroup =
          await GroupsFirebaseRepository().getSpecificGroup(e.group.id);
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
    final validator = await RoadsFirebaseRepository().onTapRoad(road);
    notifyListeners();
  }

  Future<void> onTapJoinRoads(Road road) async {
    road.numberParticipants = road.numberParticipants + 1;
    road.competitorRoad.add(BiuxUser(id: user.id, names: user.names));
    final validator = await RoadsFirebaseRepository().onTapRoad(road);
    notifyListeners();
  }
}
