import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupListScreenBloc extends ChangeNotifier {
  List<Group> listGroup = [];
  List<Group> listFilterGroup = [];
  BiuxUser user = BiuxUser();
  List<City> listCities = [];
  final FocusNode focusNodeCity = FocusNode();
  final FocusNode focusNodeGrupo = FocusNode();
  final searchCityController = TextEditingController();
  final searchGroupController = TextEditingController();

  GroupListScreenBloc() {
    loadData();
  }

  Future<void> loadData() async {
    getGroupList();
    getCities();
  }

  Future<List<Group>> getGroupList() async {
    if (searchCityController.text.isEmpty)
      listGroup = await GroupsFirebaseRepository().getGroups();
    else
      listGroup = await GroupsFirebaseRepository()
          .getFilterGroups(searchCityController.text);
    notifyListeners();
    return listGroup;
  }

  Future<void> filterCroup() async {
    if (searchCityController.text.isEmpty)
      listFilterGroup = await GroupsFirebaseRepository().getGroups();
    else
      listFilterGroup = await GroupsFirebaseRepository()
          .getFilterGroups(searchCityController.text);
    listGroup = listFilterGroup
        .where((groups) => groups.name
            .toLowerCase()
            .contains(searchGroupController.text.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> getUser() async {
    String? userId = await LocalStorage().getUserId();
    final dataUser = await UserFirebaseRepository().getUserId(userId!);
    user = dataUser;
    notifyListeners();
  }

  Future<void> getCities() async {
    final dataCities = await CitiesFirebaseRepository().getCities();
    listCities = dataCities;
    notifyListeners();
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

  Future<void> onTapCities(String nameCity) async {
    searchCityController.text = nameCity;
    getGroupList();
    focusNodeCity.unfocus();
    notifyListeners();
  }

  Future<bool> setState() async {
    searchGroupController.clear();
    notifyListeners();
    return Future.value(false);
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
}
